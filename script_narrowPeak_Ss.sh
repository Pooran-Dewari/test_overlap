conda activate intervene

######## get filenames prefixes ###########
for fname in *summits.bed
do
  tmp=$(echo "$fname" | awk -F '_' '{print $1"_"$2}' )
  newfname=${tmp}
  echo $newfname >> summits_tmp.txt
done;

sort -u summits_tmp.txt > summits_list.txt

rm summits_tmp.txt
################################## use filenames prefixes to create sub-directories for each stage  & mv files

while read i;
do
mkdir "$i"
cp Ss.txt "$i" #copy the genome file for slop later
find . -name "$i" -prune -o -type f -exec \
    grep -q "$i" "{}" \; -exec cp "{}" "$i" \;
done <  summits_list.txt


#######################################
while read i;
do
    cd "$i"
    ls *summits.bed | while read SUMMITS; 
        do cat $SUMMITS | grep -v 'CAJ' > $SUMMITS"_filtered.bed"; 
           #slop 200 bp both sides
           bedtools slop -i $SUMMITS"_filtered.bed" -g Ss.txt -b 200 > $SUMMITS"_slop_200bp.bed";done
    #intervene
    intervene venn -i *slop_200bp.bed --title "$i" --names=R1,R2,R3 --output "$i"_overlap --save-overlaps
        cd "$i"_overlap/sets 
        #create overlap df for R
        wc -l *R[123456].bed | awk 'NR==1 {print "file","overlap"}; {print $2, $1}' OFS='\t' | grep -v 'total' > "$i"_overlap.txt
    cd ../../..
done <  summits_list.txt

#extract histone mark from filenames, create a directory for the histone mark, and move overlap.txt files onto it
cat summits_list.txt | awk '{print substr($0,5,9)}' | uniq > dir_name.txt
dir_name=$(head -n 1 dir_name.txt)

mkdir $dir_name"_vennDiagrams"
mv **/*/*/*.txt $dir_name"_vennDiagrams"

#remove uneccessary files
rm summits_list.txt
rm dir_name.txt

conda deactivate

#cp Euler.R $dir_name
cd $dir_name"_vennDiagrams"
Rscript ../Euler.R
cd ..

echo "*******************************"
echo "**************bye for now******"
