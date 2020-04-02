cd exdata/
###
####set up the envernmental variables
out_base=ALL.chr22
bed=${out_base}.bed
bim=${out_base}.bim
fam=${out_base}.fam
cpus=1

#####
##### plink formatted file
plink2 --vcf ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.MAC10.01p.vcf.gz --double-id --make-bed -out ${out_base}

#####
##### run KING
king -b ${bed} --kinship --cpus ${cpus} --prefix ${out_base}  > ${out_base}.out

#####
##### filter kinship file
awk '($8>=0.0442){print $0}' ${out_base}.kin0 > ${out_base}.kin0.related

R CMD BATCH "--args ${out_base}" unrelated_third_degree.R > unrelated_third_degree.out

gzip -c ${out_base}.kin > ${out_base}.kin.gz
gzip -c ${out_base}.kin0 > ${out_base}.kin0.gz
gzip -c ${out_base}.kin0.related > ${out_base}.kin0.related.gz
gzip -c ${out_base}.out > ${out_base}.out.gz
gzip -c ${out_base}.kin0.unrelated3d.tsv > ${out_base}.kin0.unrelated3d.tsv.gz
