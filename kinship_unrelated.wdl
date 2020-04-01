task kin2unrelated {
	File bim
  File bed
  File fam
  Int disk
	Float memory
	Int cpus

	String out_base = basename(bed, ".vcf.gz")


	command {
git clone https://github.com/seuchoi/KING.git
king -b ${bed} --kinship --prefix ${out_base} --cpus ${cpus}> ${out_base}.out

awk '($8>=0.0442){print $0}' ${out_base}.kin0 > ${out_base}.kin0.related

gzip -c ${out_base}.kin > ${out_base}.kin.gz
gzip -c ${out_base}.kin0 > ${out_base}.kin0.gz
gzip -c ${out_base}.kin0.related > ${out_base}.kin0.related.gz
gzip -c ${out_base}.out > ${out_base}.out.gz


  }

	runtime {
		docker: "schoi/king:latest"
		disks: "local-disk ${disk} HDD"
		memory: "${memory} GB"
		cpu : "${cpus}"
	}

	output {
		File out_file1 = "${out_base}.kin"
    File out_file2 = "${out_base}.kin0"
    File out_file2 = "${out_base}.out"
	}
}

workflow makegds {
	Array[File] vcf_files
	Int this_disk
	Int this_cpus
	Float this_memory

	scatter(this_file in vcf_files) {
		call runGds {
			input: vcf = this_file, disk = this_disk, memory = this_memory, cpus = this_cpus
		}
	}


	output {
		Array[File] gds_files = runGds.out_file1
		Array[File] out_files = runGds.out_file2
	}
}
