
<!-- README.md is generated from README.Rmd. Please edit that file -->

<img src="man/figures/logo_ingestr.svg" align="right" width=150px>

# ingestr

**An R package for reading environmental data from raw formats into
data.frames.**

[![Travis-CI Build
Status](https://travis-ci.org/jpshanno/ingestr.svg?branch=master)](https://travis-ci.org/jpshanno/ingestr)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/jpshanno/ingestr?branch=master&svg=true)](https://ci.appveyor.com/project/jpshanno/ingestr)
[![Coverage
Status](https://img.shields.io/codecov/c/github/jpshanno/ingestr/master.svg)](https://codecov.io/github/jpshanno/ingestr?branch=master)

This is project was initiated at the inaugural [IMCR
Hackathon](https://github.com/IMCR-Hackathon/HackathonCentral) hosted by
the [Environmental Data
Institute](https://environmentaldatainitiative.org/). The end product of
this effort will be an R package on CRAN. The package will primarily
deal with reading data from files, though there will be some utilities
for initial cleanup of files such as removing blank rows and columns at
the end of a CSV file. Our work at the hackathon focused on package
infrastructure, standardization, and template construction.

The guiding principles of ingestr are that

1.  All sources of environmental-related data should be easy to read
    directly
2.  Reading in data should provide a standard output
3.  Header information contained within sensor data files should be
    stored in a standard, easily readable format
4.  Associating imported data with its original source is the first step
    towards good data provenance records and reproducibility
5.  We don’t know about every common sensor and love contributions of
    code or sensors that need support. See
    [issues](https://github.com/jpshanno/ingestr/issues) to submit an
    example data file, and see our [contributing
    guide](https://jpshanno.github.io/ingestr/CONTRIBUTING) to
    contribute code.

## Installation

You can install ingestr from github with:

``` r
# install.packages("devtools")
devtools::install_github("jpshanno/ingestr")

# or from source
ingestr_source <- file.path(tempdir(), "ingestr-master.zip")
download.file("https://github.com/jpshanno/ingestr/archive/master.zip",
              ingestr_source)
unzip(ingestr_source,
      exdir = dirname(ingestr_source))
install.packages(sub(".zip$", "", ingestr_source), 
                 repos = NULL,
                 type = "source")
```

## Ingesting Data

Each ingestr function to read in data starts with `ingest_` to make
autocomplete easier. We are targetting any source of environmental data
that returns data in a standard format: native sensor files, delimited
outputs, HTML tables, PDF tables, Excel sheets, API returns, …

Running any ingest function will read in the data and format the data
into a clean R data.frame. Column names are taken directly from the data
file, and users have the option to read the header information into a
temporary file that can then be loaded using `ingest_header()`.  
All data and header data that are read in will have the data source
appended to the data as a column called input\_source.

### Sensor and Instrument Data

Many sensors provide their output as delimited files with header
information contained above the recorded data.

``` r
campbell_file <- 
  system.file("example_data",
              "campbell_scientific_tao5.dat",
              package = "ingestr")

campbell_data <- 
  ingest_campbell(input.source = campbell_file,
                  export.header = TRUE,
                  add.units = TRUE,
                  add.measurements = TRUE)

str(campbell_data)

campbell_header <- 
  ingest_header(input.source = campbell_file)

str(campbell_header)
```

### Formatted Non-Sensor Data Sources

Some environmental data is published online as html elements. This data
can be difficult to read directly from the websites where they are
hosted into R. To facilitate access, we have created functions that
parse the html so that this data can be directly downloaded in R. To
track the provenance of these data, the column input\_source is
populated by the URL location from which the data were downloaded.

``` r

PDO_data <- 
  ingest_PDO(input.source = "http://jisao.washington.edu/pdo/PDO.latest",  
             end.year = NULL,
             export.header = TRUE)
#> Header info for http://jisao.washington.edu/pdo/PDO.latest has been saved to a temporary file. Run ingest_header('http://jisao.washington.edu/pdo/PDO.latest') to load the header data.

str(PDO_data)
#> 'data.frame':    121 obs. of  14 variables:
#>  $ YEAR        : chr  "1901" "1902" "1903" "1904" ...
#>  $ JAN         : chr  "0.79" "0.82" "0.86" "0.63" ...
#>  $ FEB         : chr  "-0.12" "1.58" "-0.24" "-0.91" ...
#>  $ MAR         : chr  "0.35" "0.48" "-0.22" "-0.71" ...
#>  $ APR         : chr  "0.61" "1.37" "-0.50" "-0.07" ...
#>  $ MAY         : chr  "-0.42" "1.09" "0.43" "-0.22" ...
#>  $ JUN         : chr  "-0.05" "0.52" "0.23" "-1.53" ...
#>  $ JUL         : chr  "-0.60" "1.58" "0.40" "-1.58" ...
#>  $ AUG         : chr  "-1.20" "1.57" "1.01" "-0.64" ...
#>  $ SEP         : chr  "-0.33" "0.44" "-0.24" "0.06" ...
#>  $ OCT         : chr  "0.16" "0.70" "0.18" "0.43" ...
#>  $ NOV         : chr  "-0.60" "0.16" "0.08" "1.45" ...
#>  $ DEC         : chr  "-0.14" "-1.10" "-0.03" "0.06" ...
#>  $ input_source: chr  "http://jisao.washington.edu/pdo/PDO.latest" "http://jisao.washington.edu/pdo/PDO.latest" "http://jisao.washington.edu/pdo/PDO.latest" "http://jisao.washington.edu/pdo/PDO.latest" ...

PDO_header <- 
  ingest_header(input.source = "http://jisao.washington.edu/pdo/PDO.latest")
#> Header data was loaded from cached results created when http://jisao.washington.edu/pdo/PDO.latest was ingested previously in this R session.

str(PDO_header)
#> 'data.frame':    1 obs. of  2 variables:
#>  $ header_text : chr "PDO INDEX If the columns of the table appear without formatting on your browser, use http://research.jisao.wash"| __truncated__
#>  $ input_source: chr "http://jisao.washington.edu/pdo/PDO.latest"
```

### Batch Ingests

Sensor data stored in folders is available for batch import using
`ingest_` functions, or any other function that reads in data (i.e.
`read.csv`, `readr::read_csv`. When a directory is read in file names
are checked for duplicates, and imported data is checked for duplicate
file contents. The user is warned and can choose to suppress the warning
or remove the duplicates. Parallel bath processing is supported for
large batch processing (requires the
[parallel](https://stat.ethz.ch/R-manual/R-devel/library/parallel/doc/parallel.pdf)
package.

``` r
temperature_data <- 
  ingest_directory(directory = "campbell_loggers",
                   ingest.function = ingest_campbell,
                   pattern = ".dat")

temperature_data
```

### Incorporate File Naming Conventions as Data

Filenames generally include information about the data collected: site,
sensor, measurement type, date collected, etc. We are working on a
generalized approach (probably just a function or two) that would split
the filename into data columns using a template would be very useful.  
For example if a set of file names read as “site-variable-year”
(152-soil\_moisture-2017.csv, 152-soil\_temperature-2017.csv,
140-soil\_moisture\_2017.csv, etc), then the function would take an
argument supplying the template as column headers: “site-variable-year”
with either delimiters or the length of each variable to enable
splitting. These functions will likely build off of the great work done
on `tidyr::separate()` and we suggest using that until we have
incorporated a solution.

## Preliminary Clean-up Utilities

Basic data cleaning utilities will be included in ingestr. These will
include identifying duplicate rows, empty rows, empty columns, and
columns that contain suspicious entries (i.e. “.”). These utilities will
be able to flag or correct the problems depending upon user preference.
In keeping with our commitment to data provenance and reproduciblity all
cleaning utilities will provide a record of identified and corrected
issues which can be saved by the user and stored with the final dataset.

## QAQCR (quacker)

While ingestr is focused on getting data into R and running preliminary
checks, another group at the IMCR Hackathon focused on quality assurance
checks for environmental data.
[qaqcr](https://github.com/IMCR-Hackathon/qaqc_tools) provides a simple,
standard way to apply the quality control checks that are applicable to
your data.

The packages are the start of a larger ecosystem including
[EMLassemblyline](https://github.com/EDIorg/EMLassemblyline) for
environmental data management to create a convenient, reproducible
workflow moving from raw data to archived datasets with rich EML
metadata.
