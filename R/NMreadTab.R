##' Read an output table file from NONMEM
##'
##' Read a table generated by a $TABLE statement in Nonmem. Generally,
##' these files cannot be read by read.table or similar because
##' formatting depends on options in the $TABLE statement, and because
##' Nonmem sometimes includes extra lines in the output that have to
##' be filtered out. NMreadTab can do this automatically based on the
##' table file alone.
##'
##' @param file path to NONMEM table file
##' @param tab.count Nonmem includes a counter of tables in the
##'     written data files. These are often not useful. However, if
##'     tab.count is TRUE (default), a counter of tables is included
##'     as a column called TABLENO. Just notice, the table numbers in
##'     TABLENO are just cumulatively counting the number of tables
##'     reported in the file. TABLENO is not true to the actual table
##'     number as given by Nonmem.
##' @param header Use header=FALSE if table was created with NOHEADER
##'     option in $TABLE.
##' @param skip The number of rows to skip. The default is skip=1 if
##'     header==TRUE and skip=0 if header==FALSE.
##' @param quiet logical stating whether or not information is printed
##'     about what is being done. Default can be configured using
##'     NMdataConf.
##' @param as.fun The default is to return data as a data.frame. Pass
##'     a function (say tibble::as_tibble) in as.fun to convert to
##'     something else. If data.tables are wanted, use
##'     as.fun="data.table". The default can be configured using
##'     NMdataConf.
##' @param ... Arguments passed to fread.
##' @return The Nonmem table data.
##' @details The actual reading of data is based on
##'     data.table::fread. Generally, the function is fast thanks to
##'     data.table.
##' @import data.table
##' @family DataRead
##' @export


NMreadTab <- function(file,tab.count=TRUE,header=TRUE,skip,quiet,as.fun,...) {
    
#### Section start: Dummy variables, only not to get NOTE's in pacakge checks ####

    TABLE <- NULL
    TABLENO <- NULL

### Section end: Dummy variables, only not to get NOTE's in pacakge checks

    
    ## arg checks
    if(!is.character(file)) stop("file should be a character string",call.=FALSE)
    if(!file.exists(file)) stop("argument file is not a path to an existing file.",call.=FALSE)

    if(missing(as.fun)) as.fun <- NULL
    as.fun <- NMdataDecideOption("as.fun",as.fun)

    if(missing(quiet)) quiet <- NULL
    quiet <- NMdataDecideOption("quiet",quiet)
    
    if(!quiet){
        message("Reading data using fread")
    }
    if(missing(skip)){
        skip <- 1
        if(!header) skip <- 0
    }
    dt1 <- fread(file,fill=TRUE,header=header,skip=skip,...)

    cnames <- colnames(dt1)
    if(!quiet){
        message("Adding table numbers to data")
    }
    if(tab.count){
        ## find table numbers
        dt1[grep("^TABLE +NO\\. +[0-9]+ *$",as.character(get(cnames[1])),invert=FALSE,perl=TRUE),TABLE:=get(cnames[1])]
        if(header){
            dt1[,TABLENO:=cumsum(!is.na(TABLE))+1]
        }
        dt1[,TABLE:=NULL]
    }
    if(!quiet){
        message("getting rid of non-data rows")
    }
    dt1 <- dt1[grep("^ *[[:alpha:]]",as.character(get(cnames[1])),invert=TRUE,perl=TRUE)]

    cols.dup <- duplicated(colnames(dt1))
    if(any(cols.dup)){
        messageWrap(paste0("Cleaned duplicated column names: ",paste(colnames(dt1)[cols.dup],collapse=",")),fun.msg=message)
        dt1 <- dt1[,unique(cnames),with=FALSE]
        
    }

    ## columns added and clened since cnames was created. 
    cnames <- colnames(dt1)
    dt1[,(cnames):=lapply(.SD,as.numeric)]

    dt1 <- as.fun(dt1)
    
    return(dt1)
}
