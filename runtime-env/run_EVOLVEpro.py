from evolvepro.src.evolve import evolve_experimental

import sys

script,output=sys.argv

if output:
    protein_name = 'kelsic'
    embeddings_base_path = output+'/content/output'
    embeddings_file_name = 'kelsic_esm1b_t33_650M_UR50S.csv'
    round_base_path = output+'/content/EvolvePro/colab/rounds_data'
    wt_fasta_path = output+"/content/output/kelsic_WT.fasta"
    number_of_variants = 12
    output_dir = output+'/content/output/'
    rename_WT = False
else:
    print("output no found")
    sys.exit()


print("run Round1 tasks")
round_name = 'Round1'
round_file_names = ['kelsic_Round1.xlsx']

this_round_variants, df_test, df_sorted_all = evolve_experimental(
    protein_name,
    round_name,
    embeddings_base_path,
    embeddings_file_name,
    round_base_path,
    round_file_names,
    wt_fasta_path,
    rename_WT,
    number_of_variants,
    output_dir
)



print("run Round2 tasks")
round_name = 'Round2'
round_file_names = ['kelsic_Round1.xlsx', 'kelsic_Round2.xlsx']

this_round_variants, df_test, df_sorted_all = evolve_experimental(
    protein_name,
    round_name,
    embeddings_base_path,
    embeddings_file_name,
    round_base_path,
    round_file_names,
    wt_fasta_path,
    rename_WT,
    number_of_variants,
    output_dir
)


round_name = 'Round3'
round_file_names = ['kelsic_Round1.xlsx', 'kelsic_Round2.xlsx', 'kelsic_Round3.xlsx']

this_round_variants, df_test, df_sorted_all = evolve_experimental(
    protein_name,
    round_name,
    embeddings_base_path,
    embeddings_file_name,
    round_base_path,
    round_file_names,
    wt_fasta_path,
    rename_WT,
    number_of_variants,
    output_dir
)


round_name = 'Round4'
round_file_names = ['kelsic_Round1.xlsx', 'kelsic_Round2.xlsx', 'kelsic_Round3.xlsx', 'kelsic_Round4.xlsx']

this_round_variants, df_test, df_sorted_all = evolve_experimental(
    protein_name,
    round_name,
    embeddings_base_path,
    embeddings_file_name,
    round_base_path,
    round_file_names,
    wt_fasta_path,
    rename_WT,
    number_of_variants,
    output_dir
)


round_name = 'Round5'
round_file_names = ['kelsic_Round1.xlsx', 'kelsic_Round2.xlsx', 'kelsic_Round3.xlsx', 'kelsic_Round4.xlsx', 'kelsic_Round5.xlsx']

this_round_variants, df_test, df_sorted_all = evolve_experimental(
    protein_name,
    round_name,
    embeddings_base_path,
    embeddings_file_name,
    round_base_path,
    round_file_names,
    wt_fasta_path,
    rename_WT,
    number_of_variants,
    output_dir
)


def plot_evo():
    from evolvepro.src.plot import read_exp_data, plot_variants_by_iteration
    round_base_path = output+'/content/EvolvePro/colab/rounds_data'
    round_file_names = ['kelsic_Round1.xlsx', 'kelsic_Round2.xlsx', 'kelsic_Round3.xlsx', 'kelsic_Round4.xlsx', 'kelsic_Round5.xlsx']
    wt_fasta_path = output+"/content/output/kelsic_WT.fasta"
    ##
    df = read_exp_data(round_base_path, round_file_names, wt_fasta_path)
    plot_variants_by_iteration(df, activity_column='activity', output_dir=output_dir, output_file="kelsic")


plot_evo




