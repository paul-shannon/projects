cat chr1.bed chr2.bed chr3.bed chr4.bed chr5.bed chr6.bed chr7.bed chr8.bed chr9.bed chr10.bed chr11.bed chr12.bed chr13.bed chr14.bed chr15.bed chr16.bed chr17.bed chr18.bed chr19.bed chr20.bed chr21.bed chr22.bed > brain_hint_unsorted.bed
#sort -k1,1n -k2,2n brain_hint_unsorted.bed > brain_hint.bed
sort -k 1.4,1n -k2,2 brain_hint_unsorted.bed > brain_hint.bed
