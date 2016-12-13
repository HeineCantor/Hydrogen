# Dichiarazione delle costanti per il multiboot header

.set ALIGN,		1<<0				# allineamento moduli caricati
.set MEMINFO,	1<<1				# mappatura della memoria
.set FLAGS,		ALIGN | MEMINFO		# flag tra le due costanti per multiboot
.set MAGIC,		0x1BADB002			# posizione dell'header (per il bootloader)
.set CHECKSUM,	-(MAGIC + FLAGS)	# controlla la somma per verificare la compatibilità con multiboot

# Costanti standard per multiboot
# NOTA: Il bootloader cercherà queste costanti come firma multiboot nei primi
# 8 KiB del file kernel, allineati a margine di 32 bit. La firma è nella sua
# sezione quindi l'header sarà forzatamente nei primi 8 KiB del file kernel.

.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# Il multiboot standard non definisce il valore del registro ESP (stack pointer)
# ed è il kernel a doversene occupare per implementare uno stack. Questo alloca
# un po' di spazio per un piccolo stack, creando un simbolo alla fine del file,
# quindi allocando 16384 bytes e infine creando un simbolo all'inizio, infatti
# su architettura x86 lo stack procede al contrario. Lo stack è nella sua posi-
# zione e quindi può essere marcato con nobits, il che significa che il file
# del kernel sarà più piccolo dato che non conterrà uno stack non inizializzato.
# Lo stack in x86 ha allineamento a 16 byte (questo dallo standard System V ABI).
# Il compilatore assume che lo stack sarà allineato correttamente e un errato
# allineamento dello stack porterebbe a conseguenze impreviste.

.section .bss
.align 16
stack_bottom:
.skip 16384		#16 KiB
stack_top:

# Lo script del linker specifica _start come punto d'entrata al kernel e il
# bootloader salterà a questa posizione quando il kernel sarà stato caricato.
# Non ha senso ritornare a questa funzione quando il bootloader ha finito
# ciò che doveva fare.

.section .text
.global _start
.type _start, @function
_start:
		# Il bootloader ha caricato l'utente in modalità a 32 bit su archi-
		# tettura x86. Gli interrupt vengono disabilitati, insieme al paging.
		# Lo stato del processore è come viene definito dal multiboot. Il 
		# kernel ha pieno controllo della CPU. Il kernel può solo fare uso
		# dell'hardware e ogni tipo di codice che ne fa parte. Non ci sono
		# restrizioni di sicurezza. Si ha il controllo assoluto sulla macchina.
		
		# Per impostare lo stack, settiamo il registro ESP a puntare alla
		# cima (top) dello stack. Questo è necessario farlo in assembly.
		# NOTA: un linguaggio di programmazione ad alto livello come il C
		# non funzionerebbe senza stack.
		
		mov $stack_top, %esp
		
		# Qui dovremmo inizializzare le funzioni cruciali del processore.
		# Tuttavia lasciamo in sospeso poiché non sono ancora incluse le
		# istruzioni fondamentali (floating, paging e compagnia bella).
		
		# L'ABI richiede che lo stack sia allineato a 16 byte alla chiama-
		# ta dell'istruzione (che poi pusha il puntatore di ritorno di
		# una grandezza di 4 byte). Lo stack era originariamente allineato
		# a 16 byte e l'abbiamo quindi pushato un multiplo di 16 byte fino
		# a che l'allineamento sia preservato e la chiamata sia definita
		
		call kernel_main	#la famosa chiamata
		
		# Se il sistema non ha più niente da fare:
		# 
		# 1) Disabilita gli interrupt con cli (clear interrupt in eflags).
		# 	 Di norma sono già disabilitati dal bootloader quindi non è neces-
		#	 sario, ma ricordiamo che in seguito potrebbero essere abilitati
		#	 ed è meglio prevenire la chiamata del kernel.
		# 2) Aspetta fino al prossimo interrupt per poi arrivare con istru-
		#	 zione halt. Essendo essi disabilitati, questo bloccherà la mac-
		#	 china.
		# 3) Salta alla prossima istruzione halt se dovesse in qualche caso
		#	 risvegliarsi per un interrupt non maskabile o da una modalità
		#	 di gestione del bootloader
		
		cli
1:		hlt
		jmp 1b

# Impostiamo la grandezza del simbolo di _start alla posizione corrente '.'
# meno il suo _start. Questo è utile quando si debugga o quando si imple-
# menta un trace di chiamate.

.size _start, . - _start
