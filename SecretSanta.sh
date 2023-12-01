#!/bin/zsh

# echo "What year is this year?"
# read year

# names=()
# echo "Please input the names of the participants, separated by enter. When done with entering names, simply enter an empty line."
# while read name; do
#     if [ -z "$name" ];
#     then
#         break
#     fi
#     names+=(${name})
# done
# # printf -v joined '%s,' "${names[@]}"
# echo "The participants of ${year}'s Secret Santa are: "
# echo $names

if [ $# -eq 0 ];
then
    echo "$0: Please provide a file input for participant names. "
    exit 1
fi
names_file=$1

names=()
while read line; do
    names+=(${line})
done <$names_file
N=${#names[@]}
echo "$N participants read: $names."

echo "Enter a pass phrase to encode the names:"
read pass_phrase
echo "Using pass phrase '${pass_phrase}' to encode the names..."
touch TEMP_hashes.txt; echo -n '' > TEMP_hashes.txt # prepare TEMP_hashes.txt to be an empty file
hashes=()
for i in {1..$N}; do
    hash=`md5sum <<< "${names[i]}${pass_phrase}" | awk '{ print $1 }'`
    hashes+=(${hash})
    echo $hash >> TEMP_hashes.txt
done


keep_shuffling=1
while [[ $keep_shuffling -eq 1 ]]; do
    shuf $names_file > TEMP_shuffled_names.txt
    shuffled_names=()
    while read line; do
        shuffled_names+=(${line})
    done <TEMP_shuffled_names.txt
    # echo "Shuffled names: $shuffled_names."
    keep_shuffling=0
    for i in {1..$N}; do
        if [[ $names[i] == $shuffled_names[i] ]]
        then
            # echo "Found a fixed point. Reshuffling..."
            keep_shuffling=1
            break
        fi
    done
done

touch .HIDE_assignments.txt; echo -n '' > HIDE_assignments.txt
for i in {1..$N}; do
    echo "$names[i] is the Secret Santa for $shuffled_names[i]." >> .HIDE_assignments.txt
done

# rm TEMP_*
