#from evolvepro.src.process import generate_wt, generate_single_aa_mutants
import os, sys


if __name__ == '__main__':

    script, outputdir=sys.argv

    if outputdir:
        #print(os.path.abspath(outputdir+'/content/output/kelsic_WT.fasta'))
        generate_wt('MAKEDNIEMQGTVLETLPNTMFRVELENGHVVTAHISGKMRKNYIRILTGDKVTVELTPYDLSKGRIVFRSR', output_file=outputdir+'/content/output/kelsic_WT.fasta')
        generate_single_aa_mutants('/content/output/kelsic_WT.fasta', output_file=outputdir+'/content/output/kelsic.fasta')
    else:
        print("NO OUTPUTDIR FOUND")
        sys.exit()
