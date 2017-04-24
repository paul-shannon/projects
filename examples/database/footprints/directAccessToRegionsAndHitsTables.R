library(RPostgreSQL)
database.host <- "bddsrds.globusgenomics.org"

# first, the hg38 gtf table
db.hg38 <- dbConnect(PostgreSQL(), user= "trena", password="trena", dbname="hg38", host=database.host)
dbListTables(db.hg38)   # [1] "motifsgenes" "gtf"
query <- "select * from gtf where moleculetype='gene' and gene_biotype='protein_coding' limit 5"
dbGetQuery(db.hg38, query)[, c(1:3,5,10)]

# now, the footprint database, brain, hint as footprint caller, two tables: regions and hits
# the regions table has every unique chromosome:start-end region in the whole genome in which
# one or more samples had a footprint called.  there are no duplicates in the regions table
# the hits table has the actual footprint information, sample ID, score,
db.fp  <- dbConnect(PostgreSQL(), user= "trena", password="trena", dbname="brain_hint", host=database.host)

chromosome <- "chr5"
start <- 88717221
end   <- 88717502

query.part.1 <- "select loc, chrom, start, endpos from regions"
query.part.2 <- sprintf("where chrom='%s' and start >= %d and endpos <= %d", chromosome, start, end)
query.regions <- paste(query.part.1, query.part.2)

tbl.regions <- dbGetQuery(db.fp, query.regions)   # just 5 rows

# with the unique regions in range now known, use the loc key to extract the
# corresponding actual footprints.
# the regions table is indexed on chr, start, end
# the hits table is indexed on loc
# this two-step approach, avoiding table joins, makes for efficient access to
# footprints in your region of interest.

loc.set <- sprintf("('%s')", paste(tbl.regions$loc, collapse="','"))
query.hits <- sprintf("select * from hits where loc in %s", loc.set)
tbl.hits <- dbGetQuery(db.fp, query.hits)
tbl.out <- merge(tbl.regions, tbl.hits, on="loc")
