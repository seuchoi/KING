task kin2unrelated {
	File bim
  File bed
  File fam
  Int disk
	Float memory
	Int cpus

	String out_base = basename(bed, ".bed")


	command {

git clone https://github.com/seuchoi/KING.git

king -b ${bed} --kinship --prefix ${out_base} --cpus ${cpus}> ${out_base}.out

awk '($8>=0.0442){print $0}' ${out_base}.kin0 > ${out_base}.kin0.related

R CMD BATCH "--args ${out_base}" ./unrelated_third_degree.R > unrelated_third_degree.out

gzip -c ${out_base}.kin > ${out_base}.kin.gz
gzip -c ${out_base}.kin0 > ${out_base}.kin0.gz
gzip -c ${out_base}.kin0.related > ${out_base}.kin0.related.gz
gzip -c ${out_base}.out > ${out_base}.out.gz
gzip -c ${out_base}.kin0.unrelated3d.tsv > ${out_base}.kin0.unrelated3d.tsv.gz


  }

	runtime {
		docker: "schoi/king:latest"
		disks: "local-disk ${disk} HDD"
		memory: "${memory} GB"
		cpu : "${cpus}"
	}

	output {
		File kinship1 = "${out_base}.kin.gz"
    File kinship2 = "${out_base}.kin0.gz"
    File related = "${out_base}.out.related.gz"
    File unrelated = "${out_base}.kin0.unrelated3d.tsv.gz"
    File outfile = "${out_base}.out.gz"
	}
}

workflow king {
  File this_bim
  File this_bed
  File this_fam
	Int this_disk
	Int this_cpus
	Float this_memory

			call kin2unrelated {
			input: bim = this_file, bed = this_bed, fam = this_fam, disk = this_dis, memory = this_memory, cpus = this_cpus
		    }



	output {
		File kinship1 = kin2unrelated.kinship1
		File kinship2 = kin2unrelated.kinship2
		File related = kin2unrelated.related
		File unrelated = kin2unrelated.unrelated
		File outfile = kin2unrelated.outfile

	}
}
