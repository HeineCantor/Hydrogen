/* Il bootloader guarderà quest'immagine per l'esecuzione */

ENTRY(_start)

/* Dichiarazione delle sezioni del file object */

SECTIONS
{
	/* Le sezioni partono convenzionalmente da 1 MiB dell'object */
	. = 1M;
	
	/* Inseriamo prima l'header multiboot, dato che deve trovarsi
	   all'inizio dell'immagine o il bootloader non lo caricherà.
	   Quindi posizioniamo la sezione del testo. */
	.text BLOCK(4K) : ALIGN(4K)
	{
		*(.multiboot)
		*(.text)
	}
	
	/* Dati Read-only (sola lettura) */
	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.rodata)
	}
	
	/* Dati lettura e scrittura inizializzati */
	.data BLOCK(4K) : ALIGN(4K)
	{
		*(.data)
	}
	
	/* Dati lettura e scrittura non inizializzati */
	.bss BLOCK(4K) : ALIGN(4K)
	{
		*(COMMON)
		*(.bss)
	}
}
