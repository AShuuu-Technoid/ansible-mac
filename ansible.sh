#!/bin/bash

add_ssh_key() {
    read -ep "Enter SSH Public Key Path : " path
    path_list=$(echo $path | tr "," "\n")
    for key_path in $path_list; do
        ssh_path="  - $key_path"
        sed -i -e "s+.*ssh_key.*+&\n$ssh_path+" group_vars/all
    done
}
rm_ssh_key() {
    path_list=$(echo $path | tr "," "\n")
    for key_path in $path_list; do
        ssh_path="  - $key_path"
        sed -i -e "s+$ssh_path++g" group_vars/all
        # sed -i -e "s+.*ssh_key.*+&\n$ssh_path+" group_vars/all
    done
}
add_ssh_key_no() {
    sed -i '' '51,56 s/^/#/' roles/project/tasks/main.yml
}
live_uat_crt() {
    sed -i -e "s+raw:.*+raw: mkdir /data/{conf/nginx,backup,db,docker,redis,sites/{uat,live}/{public,logs}/{{ project_name }}} -p+g" roles/project/tasks/main.yml
    sed -i '' '12,56 s/#//g' roles/mysql/tasks/main.yml
    sed -i '' '46,49 s/#//g' roles/project/tasks/main.yml
    sed -i '' '8,15 s/#//g' roles/finish/tasks/main.yml
    sed -i '' '10,13 s/#//g' roles/test/tasks/main.yml
    sed -i '' '8,15 s/#//g' roles/finish/tasks/main.yml
    sed -i '' '18,30 s/#//g' roles/test/tasks/main.yml
}

live_crt() {
    sed -i -e "s+raw:.*+raw: mkdir /data/{conf/nginx,backup,db,docker,redis,sites/live/{public,logs}/{{ project_name }}} -p+g" roles/project/tasks/main.yml
    sed -i '' '35,56 s/^/#/' roles/mysql/tasks/main.yml
    sed -i '' '12,33 s/#//g' roles/mysql/tasks/main.yml
    sed -i '' '46,47 s/^/#/' roles/project/tasks/main.yml
    sed -i '' '48,49 s/#//g' roles/project/tasks/main.yml
    sed -i '' '12,13 s/#//g' roles/test/tasks/main.yml
    sed -i '' '10,11 s/^/#/' roles/test/tasks/main.yml
    sed -i '' '8,11 s/#//g' roles/finish/tasks/main.yml
    sed -i '' '12,15 s/^/#/' roles/finish/tasks/main.yml
    sed -i '' '12,13 s/#//g' roles/test/tasks/main.yml
    sed -i '' '18,23 s/#//g' roles/test/tasks/main.yml
    sed -i '' '25,30 s/^/#/' roles/test/tasks/main.yml
}
uat_crt() {
    sed -i -e "s+raw:.*+raw: mkdir /data/{conf/nginx,backup,db,docker,redis,sites/uat/{public,logs}/{{ project_name }}} -p+g" roles/project/tasks/main.yml
    sed -i '' '12,33 s/^/#/' roles/mysql/tasks/main.yml
    sed -i '' '35,56 s/#//g' roles/mysql/tasks/main.yml
    sed -i '' '48,49 s/^/#/' roles/project/tasks/main.yml
    sed -i '' '46,47 s/#//g' roles/project/tasks/main.yml
    sed -i '' '10,11 s/#//g' roles/test/tasks/main.yml
    sed -i '' '12,13 s/^/#/' roles/test/tasks/main.yml
    sed -i '' '12,15 s/#//g' roles/finish/tasks/main.yml
    sed -i '' '8,11 s/^/#/' roles/finish/tasks/main.yml
    sed -i '' '10,11 s/#//g' roles/test/tasks/main.yml
    sed -i '' '25,30 s/#//g' roles/test/tasks/main.yml
    sed -i '' '18,23 s/^/#/' roles/test/tasks/main.yml
}
live_db() {
    read -p 'Enter Live DB Name : ' live_db_name
    if [[ -z "$live_db_name" ]]; then
        echo "db name value is empty, Retry again."
        exit
    else
        live_db_nm
    fi
}

uat_db() {
    read -p 'Enter UAT DB Name : ' uat_db_name
    if [[ -z "$uat_db_name" ]]; then
        echo "db name value is empty, Retry again."
        exit
    else
        uat_db_nm
    fi
}
live_db_user() {
    read -p 'Enter Live DB Username : ' live_db_user_name
    if [[ -z "$live_db_user_name" ]]; then
        echo "db user name value is empty, Retry again."
        exit
    else
        live_db_usr_nm
    fi
}
uat_db_user() {
    read -p 'Enter UAT DB Username : ' uat_db_user_name
    if [[ -z "$uat_db_user_name" ]]; then
        echo "db user name value is empty, Retry again."
        exit
    else
        uat_db_usr_nm
    fi
}
live_uat_opt() {
    op='Please enter your choice: '
    options=("Live" "UAT" "ALL")
    select opt in "${options[@]}"; do
        case $opt in
        "Live")
            live_db
            live_db_user
            live_crt
            break
            ;;
        "UAT")
            uat_db
            uat_db_user
            uat_crt
            break
            ;;
        "ALL")
            live_db
            live_db_user
            uat_db
            uat_db_user
            live_uat_crt
            break
            ;;
        *) echo "invalid option $REPLY" ;;
        esac
    done

}
host_nm() {
    host_list=$(echo $host_name | tr "," "\n")
    sed -i '' '/ec2_user/q' hosts
    i=1
    for addr in $host_list; do
        add_name="host$i ansible_ssh_host=$addr"
        sed -i -e "s/.*ec2_user.*/&\n$add_name/" hosts
        ((i = i + 1))
    done
}
pj_nm() {
    sed -i -e "s/project_name:.*/project_name: $project_name/g" group_vars/all
}
usr_nm() {
    sed -i -e "s/user_name:.*/user_name: $user_name/g" group_vars/all
}
live_db_nm() {
    sed -i -e "s/mysql_live_db:.*/mysql_live_db: $live_db_name/g" group_vars/all
}
live_db_usr_nm() {
    sed -i -e "s/mysql_live_user:.*/mysql_live_user: $live_db_user_name/g" group_vars/all
}
uat_db_nm() {
    sed -i -e "s/mysql_uat_db:.*/mysql_uat_db: $uat_db_name/g" group_vars/all
}
uat_db_usr_nm() {
    sed -i -e "s/mysql_uat_user:.*/mysql_uat_user: $uat_db_user_name/g" group_vars/all
}
ansible_start() {
    ansible-playbook -i hosts setup.yml --verbose
}
new_setup() {
    sed -i '' '2,10 s/#//g' roles/mysql/tasks/main.yml
    sed -i '' '10,14 s/#//g' setup.yml
    sed -i '' '66,72 s/#//g' roles/project/tasks/main.yml
    sed -i '' '2,24 s/#//g' roles/project/tasks/main.yml
}
ex_setup() {
    sed -i '' '2,10 s/^/#/' roles/mysql/tasks/main.yml
    sed -i '' '10 s/^/#/' setup.yml
    sed -i '' '11,14 s/#//g' setup.yml
    sed -i '' '66,72 s/^/#/' roles/project/tasks/main.yml
    sed -i '' '2,24 s/^/#/' roles/project/tasks/main.yml
}
test_my_pg() {
    sed -i '' '13 s/#//g' setup.yml
}
test_my_pg_no() {
    sed -i '' '13 s/^/#/' setup.yml
}
start() {
    read -p 'Enter Host IP : ' host_name
    if [[ -z "$host_name" ]]; then
        echo "Host Name value is empty, Retry again."
        exit
    else
        host_nm
    fi
    read -p 'Enter Project Name : ' project_name
    if [[ -z "$project_name" ]]; then
        echo "project Name value is empty, Retry again."
        exit
    else
        pj_nm
    fi
    read -p 'Enter Username To Create : ' user_name
    if [[ -z "$user_name" ]]; then
        echo "user name value is empty, Retry again."
        exit
    else
        usr_nm
    fi
    # read -p 'Enter DB Name : ' db_name
    # if [[ -z "$db_name" ]]; then
    #     echo "db name value is empty, Retry again."
    #     exit
    # fi
    # read -p 'Enter DB Username : ' db_user_name
    # if [[ -z "$db_user_name" ]]; then
    #     echo "db user name value is empty, Retry again."
    #     exit
    # fi
    read -p 'Want To Add Both Live and UAT (Y/n) ? ' live_uat
    case $live_uat in
    [yY][eE][sS] | [yY])
        live_db
        live_db_user
        uat_db
        uat_db_user
        live_uat_crt
        ;;
    [nN][oO] | [nN])
        live_uat_opt
        ;;
    *)
        echo "Invalid Input"
        exit
        ;;
    esac
    read -p 'Want To Test Page Load (Y/n) ? ' test_pg
    case $test_pg in
    [yY][eE][sS] | [yY])
        test_my_pg
        ;;
    [nN][oO] | [nN])
        test_my_pg_no
        ;;
    *)
        echo "Invalid Input"
        exit
        ;;
    esac
    read -p 'Want To Add SSH Key (Y/n) ? ' add_key
    case $add_key in
    [yY][eE][sS] | [yY])
        add_ssh_key
        ;;
    [nN][oO] | [nN])
        add_ssh_key_no
        ;;
    *)
        echo "Invalid Input"
        exit
        ;;
    esac
    ansible_start
    rm_ssh_key
}
main() {
    read -p 'Is it new setup (Y/n) ? ' setup_qs
    case $setup_qs in
    [yY][eE][sS] | [yY])
        new_setup
        start
        ;;
    [nN][oO] | [nN])
        ex_setup
        start
        ;;
    *)
        echo "Invalid Input"
        exit
        ;;
    esac
}
main
