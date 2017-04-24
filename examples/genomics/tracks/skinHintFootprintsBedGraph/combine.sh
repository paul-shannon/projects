cat chr1.bed chr2.bed chr3.bed chr4.bed chr5.bed chr6.bed chr7.bed chr8.bed chr9.bed chr10.bed chr11.bed chr12.bed chr13.bed chr14.bed chr15.bed chr16.bed chr17.bed chr18.bed chr19.bed chr20.bed chr21.bed chr22.bed > skin_hint_unsorted.bed
#sort -k1,1n -k2,2n skin_hint_unsorted.bed > skin_hint.bed
sort -k 1.4,1n -k 2,2n -k 3,3n skin_hint_unsorted.bed > skin_hint.bed
