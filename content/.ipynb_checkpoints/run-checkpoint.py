from evolvepro.src.evolve import evolve_experimental

protein_name = 'c143'
embeddings_base_path = '/shared/content/output'
embeddings_file_name = 'c143_esm2_t48_15B_UR50D.csv'
# embeddings_file_name = 'c143_esm2_t36_3B_UR50D.csv'

round_base_path = '/shared/EvolvePro/colab/rounds_data'
wt_fasta_path = "/shared/content/output/c143_WT.fasta"
number_of_variants = 11
output_dir = '/shared/content/output/'
rename_WT = False

round_name = 'Round1'
round_file_names = ['c143_Round1.xlsx']

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

round_name = 'Round2'
round_file_names = ['c143_Round1.xlsx', 'c143_Round2.xlsx']

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
round_file_names = ['c143_Round1.xlsx', 'c143_Round2.xlsx', 'c143_Round3.xlsx']

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
round_file_names = ['c143_Round1.xlsx', 'c143_Round2.xlsx', 'c143_Round3.xlsx', 'c143_Round4.xlsx']

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

