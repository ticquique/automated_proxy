#/bin/bash
usage()
{
    echo "usage: script.sh [[[-m --module ] [-p --port] [-i --input] [-o --output]] | [-h --help]]"
}


modules=()
port=80
input_file=/etc/nginx/conf.d/default.conf.template
output_file=/etc/nginx/conf.d/default.conf

while [ "$1" != "" ]; do
    case $1 in
        -p | --port )           shift
                                port=$1
                                ;;
        -m | --module )         shift
                                modules=($1 "${modules[@]}")
                                ;;
        -i | --input )          shift
                                input_file=$1
                                ;;
        -o | --output )         shift
                                output_file=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done


LOCATIONS=""
for i in "${modules[@]}"; do
    AUX=""
    read -r -d '' AUX << EOM
    location /$i/ { 
        proxy_redirect off; 
        proxy_pass http://$i:3000;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header Authorization \$http_authorization; 
    }

EOM
    LOCATIONS="$LOCATIONS
    $AUX"
done

#envsubst PORT=$PORT LOCATIONS=$LOCATIONS envsubst '\$PORT,\$LOCATIONS' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

PORT=$port LOCATIONS=$LOCATIONS envsubst '\$PORT,\$LOCATIONS' < $input_file > $output_file
