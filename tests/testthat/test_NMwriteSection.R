context("NMwriteSection")

test_that("basic",{

    fileRef <- "testReference/NMwriteSection_1.rds"
    
    outfile <- "testOutput/xgxr011_update1.mod"
    newlines <- "$INPUT ROW ID TIME EVID CMT AMT DV FLAG STUDY EFF0"
    section <- "input"
    NMwriteSection(system.file("examples/nonmem/xgxr011.mod", package = "NMdata")
                  ,section=section
                  ,newlines=newlines
                  ,newfile=outfile)
    res <- readLines(outfile)
    expect_equal_to_reference(res,fileRef,version=2)

})




## same, with list approach
test_that("list.section",{

    fileRef <- "testReference/NMwriteSection_2.rds"

    outfile <- "testOutput/xgxr011_update2.mod"
    newlines <- "$INPUT ROW ID TIME EVID CMT AMT DV FLAG STUDY EFF0"
    section <- "input"
    NMwriteSection( system.file("examples/nonmem/xgxr011.mod", package = "NMdata")
                  ,list.section=list(input=newlines)
                  ,newfile=outfile
                   )
    res <- readLines(outfile)
    expect_equal_to_reference(res,fileRef,version=2)

})




test_that("Dependent on data.file",{

    fileRef <- "testReference/NMwriteSection_3.rds"
    
    outfile <- "testOutput/xgxr011_update1.mod"
    newlines <- "$INPUT ROW ID TIME EVID CMT AMT DV FLAG STUDY EFF0"
    section <- "input"

    NMwriteSection("testData/nonmem/xgxr011.mod"
                  ,section=section
                  ,data.file="../data/xgxr2.csv"
                  ,newlines=newlines
                  ,newfile=outfile)

    res <- readLines(outfile)
    expect_equal_to_reference(res,fileRef,version=2)

})


test_that(".mod does not exist",{

    outfile <- "testOutput/xgxr011_update1.mod"
    newlines <- "$INPUT ROW ID TIME EVID CMT AMT DV FLAG STUDY EFF0"
    section <- "input"

    res <- NMwriteSection(files="doesNotExist.mod",
                         ,section=section
                         ,newlines=newlines
                         ,newfile=outfile)
    expect_equal(res,NULL)
    
})


test_that("No files matched",{

    newlines <- "$INPUT ROW ID TIME EVID CMT AMT DV FLAG STUDY EFF0"
    section <- "input"

    res <- NMwriteSection(dir=system.file("examples/nonmem/", package = "NMdata")
                         ,file.pattern="gerge"
                         ,section=section
                         ,data.file="../data/xgxr2.csv"
                         ,newlines=newlines
                         ,newfile=outfile)

    expect_equal(res,NULL)

})


test_that("basic - write file",{

    fileRef <- "testReference/NMwriteSection_4.rds"
    
    outfile <- "testOutput/xgxr011_update1.mod"
    newlines <- "$INPUT ROW ID TIME EVID CMT AMT DV FLAG STUDY EFF0"
    section <- "input"
    NMwriteSection("testData/nonmem/xgxr011.mod" 
                  ,section=section
                  ,newlines=newlines
                  ,newfile=outfile)
    res <- readLines(outfile)
    expect_equal_to_reference(res,fileRef,version=2)

})



test_that("update INPUT based on NMgenText",{
    fileRef <- "testReference/NMwriteSection_5.rds"

    text.nm <- NMgenText(NMreadCsv("testData/data/xgxr2.csv"),capitalize = T)
    res <- NMwriteSection("testData/nonmem/xgxr011.mod",
                          list.section=text.nm["INPUT"],newfile=NULL
                          )

    ##input.new
    input.new <- NMreadSection(lines=res,section="input")
        
    expect_equal_to_reference(input.new,fileRef)
})

