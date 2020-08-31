# !/bin/bash

# Developed by Marcus Antunes on 01-06-2020 - Version v0.3
# marcusantunes@uerbas.com.br

#This Script Should Run as Zimbra User !
#Tested on Zimbra Release 8.8.15_GA_3869.RHEL6_64_20190917004220 RHEL6_64 FOSS edition, Patch 8.8.15_P9

# All this script is based on data providet to "list.txt". please check if you created it properly typing only the name of accounts

#Current Directory
pwd=$(pwd)
#List of names. Only name. Whithout @domain
LIST="$pwd/list.txt"
# Domain name (Whithout "@")
DOMAIN="domain.com"
# Suffix to rename the account. I use to keep disabled account a while in the server before deleting typying the year of changing. But change whatever fit your demand
SUFFIX="2020"
#Password for reseting passwords in batch
PASSWORD="Aa4DjUD6"


checklist()
{

	if [ -f "$LIST" ]
		then
			$execfunc
		else
			echo "Please create the file $LIST and set permissions to user zimbra"
	fi


}


# Rename the acounts listed inside the $LIST to a suffix $SUFFIX
rename()
{
         { while read USERNAME ; do

        echo "Executing Account $USERNAME"
        yes | zmprov ra $USERNAME@$DOMAIN "$USERNAME"_$SUFFIX@$DOMAIN

        done ; } < $LIST
}

# Check the size of accounts listed in $LIST and output to size-result.txt file.
sizeof()
{
         { while read USERNAME ; do

        echo "Executing Account $USERNAME"
		size=$(zmmailbox -z -m $USERNAME@$DOMAIN gms)
        echo "$USERNAME|$size" >> $pwd/size-result.txt

        done ; } < $LIST

		cat $pwd/size-result.txt
}

# Simply delete account in batch based on $LIST
deleteaccounts()
{
        { while read USERNAME ; do

                echo "Executing Account $USERNAME"
                zmprov da $USERNAME@$DOMAIN

        done ; } < $LIST

}



# Simply lock accunt in batch based on $LIST
lock()
{
        { while read USERNAME ; do

                echo "Executing Account $USERNAME"
                zmprov ma $USERNAME@$DOMAIN zimbraAccountStatus locked

        done ; } < $LIST

}


# Simply activate an account in batch based on $LIST
activate()
{
        { while read USERNAME ; do

                echo "Executing Account $USERNAME"
                zmprov ma $USERNAME@$DOMAIN zimbraAccountStatus active

        done ; } < $LIST

}

# Simply delete a distribution list in batch based on $LIST
deletelists()
{
        { while read LIST ; do

                echo "Executing List $USERNAME"
                zmprov ddl $LIST@$DOMAIN

        done ; } < $LIST

}

# Simply create a distribution list in batch based on $LIST
createlists()
{
        { while read LIST ; do

                echo "Executing List $USERNAME"
                zmprov cdl $LIST@$DOMAIN

        done ; } < $LIST

}


# Simply add users to a unique lists,
adduserstolist()
{

	read -p "Type the distribution list name that will receive the users listed in $LIST (type also the domain, eg:  user@comain.com)" distributionlist


        { while read USERNAME ; do

                echo "Executing distributionlist $USERNAME"

                zmprov adlm $distributionlist $USERNAME@$DOMAIN

        done ; } < $LIST

}



# Simply activate an account in batch on $LIST
resetpassword()
{
        { while read USERNAME ; do

                echo "Executing Account $USERNAME"
                zmprov sp $USERNAME@$DOMAIN $PASSWORD

        done ; } < $LIST

}

# Simply Config an Alias to a unique account, al aliases shoul be edited in list
configalias()
{

	read -p "Type the account that will receive e-mails from all these aliases listes in $LIST (type also the domain, eg:  user@comain.com)" recipient


        { while read USERNAME ; do

                echo "Executing Account $USERNAME"

                zmprov aaa $recipient $USERNAME@$DOMAIN

        done ; } < $LIST

}



# remove the account in $LIST from any list that was previously configured
cleanuserinlists()
{

        { while read USERNAME ; do

                        zmprov gam $USERNAME@$DOMAIN | awk -F "@" '{print $1}' > memberof.txt

                        { while read LISTA ; do

                        echo "Removendo $USERNAME da Lista $LISTA"
                        zmprov rdlm $LISTA@$DOMAIN $USERNAME@$DOMAIN

                        done ; } < memberof.txt

                        rm -rf memberof.txt

        done ; } < $LIST

}


# configure forward to specific recipient

configforward()
{

                        { while IFS='|' read USERNAME ; do

						echo "Type the recipient that will receive the forwarded emails:"
						read recipient
                        #yes | zmprov ra $USERNAME@$DOMAIN "$USERNAME"_$SUFFIX@$DOMAIN

                        zmprov ma $USERNAME@$DOMAIN zimbraPrefMailForwardingAddress $recipient@$DOMAIN
                        zmprov ma $USERNAME@$DOMAIN +zimbraPrefMailLocalDeliveryDisabled TRUE


                        done ; } < $LIST

}




case $1 in

        activate)
			execfunc=$1
                checklist
                ;;
        resetpassword)
			execfunc=$1
                checklist
                ;;
        sizeof)
			execfunc=$1
				checklist
                ;;
        rename)
			execfunc=$1
                checklist
                ;;
        configalias)
			execfunc=$1
                checklist
                ;;
        lock)
			execfunc=$1
                checklist
                ;;
		deleteaccounts)
			execfunc=$1
                checklist
                ;;
        cleanuserinlists)
			execfunc=$1
                checklist
                ;;
        configforward)
			execfunc=$1
                checklist
                ;;
				deletelists)
			execfunc=$1
								checklist
								;;
				createlists)
			execfunc=$1
			 			  checklist
			 				;;
		  	adduserstolist)
			execfunc=$1
							checklist
							;;

        *)
                echo "type parameter. check the file."
                ;;
  esac
