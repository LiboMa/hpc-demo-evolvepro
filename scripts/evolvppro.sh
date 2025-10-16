#!/bin/bash
#

SHARED_DIR=/shared
OUTPUTDIR="$SHARED_DIR/evolop-output-$(date +%s)"


RUNTIME=/shared/runtime-env/
cd /shared/EvolvePro/
git pull

source ~/.bashrc
conda activate evolvepro

mkdir $OUTPUTDIR

loadenv () {
	PIP=$(which pip)

	if [ -n $PIP ];then
		$(PIP) install -r /shared/runtime-env/reqiurements.txt
		return 0
	else
		echo "installing pip.."
		sudo apt install python3-pip
        loadenv
	fi  
}

python $RUNTIME/process.py $OUTPUTDIR
## process PLM
#
python evolvepro/plm/esm/extract.py esm1b_t33_650M_UR50S $OUTPUTDIR/content/output/kelsic.fasta $OUTPUTDIR/content/output/kelsic_esm1b_t33_650M_UR50S --toks_per_batch 512 --include mean --concatenate_dir $OUTPUTDIR/content/output

##  run round1 tasks
#python $RUNTIME/run_EVOLVEpro.py $OUTPUTDIR

