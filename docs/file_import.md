# Reading in Data

Currently, PopGen.jl provides three different file parsers with which to create a `PopObj`:

- Delimited files
- Genepop files
- Variant Call Format files

Each of the filetypes have their own file importer denoted simply by the file type: `delimited()`, `genepop()`, `bcf()`, and `vcf()`. You're encouraged to use functions, but PopGen.jl also provides you with an all-encompassing wrapper for all three called `read()`. Since `read()` already exists in `Base` Julia, this function was not exported, and must be called formally as `PopGen.read()` to avoid any unintentional dispatch errors. `PopGen.read()` uses all the same keyword arguments as do the commands specific to their filetypes, therefore you should have a look at those commands (usually the defaults suffice). 



`PopGen.read()` infers the file type from the file extension, so for it to work properly your file must end with the extensions permitted below. If you're feeling particularly rebellious and your file does not conform to these extensions (such as a genepop file with a `.gen.final.v2.seriously` extension), then feel free to use the specific file importers, since they use the same exact syntax, there is zero difference in performance, and ignore file extensions. Ultimately, what crazy extensions you give your files is your business, and we love that about you. 



### Specifying `marker = "msat"` and `OverflowError`

For genepop and delimited files, you **must** specify if your markers are microsatellites (`marker = "msat"`)  because the default is for snps.

**Why this matters:**

SNPs are Typed as 8-bit integers, whereas microsatellites are Typed as 16-bit integers. By the nature of those Types, `Int8` cannot exceed the value 127, while `Int16` is capped at 37767. Since SNP alleles will only ever be coded as values between `1` and `4`, we never have to worry about the genotype exceeding 127. Microsatellites can of course exceed 127, so we use the next-smallest Integer type for them, naively hoping no one will ever have a microsatellite allele exceeding 37767 repeats. If you have microsatellite data but don't specify `marker = "msat"`, you will receive an `OverflowError`  as soon as the file reader tries to parse an allele greater than 127 as an `Int8`.



****

## Supported File Types

### [Delimited files](delimited.md) 

Accepted extensions: `.csv`, `.tsv`, `.txt`

- files in which values are separated using a consistent delimiter, such as commas, spaces, or tabs
- first rows are column names
- each line represents a row



### [Genepop Files](genepop.md)

Accepted extensions: `.gen`, `.genepop`

- first row is a comment and skipped
- then comes list of all loci, usually 1-per-line
  - sometimes horizontally arranged and separated by commas
- populations separated by word "POP"
- sample names followed by comma and space
- genotypes separated by tabs
- genotypes represented as a combination of ploidy x 3-digits 
	- e.g. for genotype 001002 
	- allele 1 = 001
	- allele 2 = 002



### [Variant Call Format](vcf.md)

Accepted extensions: `.vcf`, `.bcf`

This format is much more abstract and can vary somewhat depending on which variant caller produced the file. If you're super duper interested in the specifications of BCF/VCF files, have a look at the [official specification documentation](http://samtools.github.io/hts-specs/VCFv4.3.pdf).