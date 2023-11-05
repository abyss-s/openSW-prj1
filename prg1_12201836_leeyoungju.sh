#!/bin/bash
# displsy menu
echo  "--------------------------"
echo  "User Name: Lee Youngju"
echo  "Student Number: 12201836"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item’"
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’"
echo "4. Delete the ‘IMDb URL’ from ‘u.item"
echo "5. Get the data about users from 'u.user’"
echo "6. Modify the format of 'release date' in 'u.item’"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo  "--------------------------"

stop="N"
until [ $stop = "Y" ]
do
    # get input from the user
    read -p "Enter your choice [1-9] " choice
    case $choice in
    # use awk for problem 1 to 3 	
    1) 
    	read -p "Please enter 'movie id'(1~1682): " movieId
    	awk -F '|' -v target="$movieId" '$1 == target' u.item 
    	;;
    2) 
    	echo -n "Do you want to get the data of ‘action’ genre movies from 'u.item’?(y/n): " 
    	read reply
    	if [ "$reply" = "y" ]; then 
            awk -F '|' '$7 == "1" { print $1 " " $2 }' ./u.item | sort -t '|' -n -k 1 | head -10
    	fi
    	;;
    3)
        read -p "Please enter 'movie id'(1~1682): " movieId
        average=$(awk -F ' ' -v target="$movieId" ' 
            BEGIN { sum=0; cnt=0 } $2 == target { sum += $3; cnt++ }
            END { printf "average rating of %d: %.5f\n", target, (cnt > 0) ? sum / cnt : 0 }
        ' ./u.data)
        echo "$average"
    	;;

    # use sed for problem 4 to 6
    4) 
        echo -n "Do you want to delete the ‘IMDb URL’ from ‘u.item’?(y/n): " 
    	read reply
    	if [ "$reply" = "y" ]; then
    		 input_file="u.item"
             output_file="u.new_item"
             awk -F '|' 'BEGIN {OFS = "|"} { $5 = ""; print }' "$input_file" > "$output_file"
             awk ' NR>=1 && NR <=10 { print }' ./u.new_item 
        fi
    	;;
    5) 
        echo -n "Do you want to get the data about users from ‘u.user’?(y/n): " 
    	read reply
    	if [ "$reply" = "y" ]; then
    		cat u.user | sed -E -e 's/--M/--male/g' -e 's/--F/--female/g'| \
    		awk -F '|' ' NR>=1 && NR<=10 { print "user " $1 " is " $2 " years old " $3 " " $4 }'
    	fi
    	;;
    6)
        echo -n "Do you want to Modify the format of ‘release data’ in ‘u.item’?(y/n): "
        read reply
        if [ "$reply" = "y" ]; then	
            awk -F '|' 'BEGIN { OFS = "|" } { months = "JanFebMarAprMayJunJulAugSepOctNovDec" } {
                split($3, date, "-");
                month = substr(months, index(months, date[2]), 3);
                new_date = date[3] sprintf("%02d", (index("JanFebMarAprMayJunJulAugSepOctNovDec", month) + 2) / 3) sprintf("%02d", date[1]);
                $3 = new_date;
                print $0;
            }' u.item > u.new_item
            awk -F '|' 'NR>=1673 && NR<=1682 { print }' u.new_item
    	fi
    	;;
    7)
        read -p "Please enter the ‘user id’(1~943): " userId
        echo -e ""
        movieIds=$(awk -v target="$userId" '$1 == target { print $2 }' ./u.data)
        AllMovieIds=$(echo "$movieIds" | sort -n | tr '\n' '|')
        echo "${AllMovieIds%|}"  
        echo -e ""
        new_MovieIds=$(echo "$movieIds" | sort -n | head -10 )
        for movieId in $new_MovieIds
        do
            movieTitle=$(awk -F "|" -v id="$movieId" '$1 == id { print $2 }' ./u.item)
            echo "$movieId|$movieTitle"
        done 
    	;;
    8)
        echo -n "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n): "
        read reply
        if [ "$reply" = "y" ]; then 
            awk -F '|' -v occupation="programmer" '
            BEGIN { OFS="\t" } $2 >= 20 && $2 <= 29 {
                sum[$1]=0;
                cnt[$1]=0;
            }
            NR == FNR { if ($4 == occupation) {
                sum[$1] += $3;
                cnt[$1]++;
                }
            }
            END { for (movieId in sum) {
                average = (cnt[movieId] > 0) ? sum[movieId] / cnt[movieId] : 0;
                printf "%d\t%.5f\n", movieId, average;
            }
        }
        ' u.user u.data u.item | sort -t $'\t' -n -k 1
        fi
        ;;
    9)
        echo "Bye!"
        break
        Exit
        ;;
    esac
 done
