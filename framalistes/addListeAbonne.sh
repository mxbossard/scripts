#! /bin/sh -e

# Initial query to load list home page
#curl 'https://framalistes.org/sympa/subindex/foo' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://framalistes.org/sympa' -H 'Connection: keep-alive' -H 'Cookie: sympa_session=78533451793110' -H 'Upgrade-Insecure-Requests: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache'

# First query to add email
#curl 'https://framalistes.org/sympa' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://framalistes.org/sympa' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Connection: keep-alive' -H 'Cookie: sympa_session=78533451793110' -H 'Upgrade-Insecure-Requests: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: Trailers' --data 'csrftoken=98f84241d7c2a794bc4ece8702fe12f6&previous_action=review&list=foo&action=add&email=n%40labomedia.net&action_add=Ajouter'

# Second query to confirm adding email
#curl 'https://framalistes.org/sympa' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://framalistes.org/sympa' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Connection: keep-alive' -H 'Cookie: sympa_session=78533451793110' -H 'Upgrade-Insecure-Requests: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data 'csrftoken=98f84241d7c2a794bc4ece8702fe12f6&email=n%40labomedia.net&action=add&list=foo&previous_action=&response_action_confirm=Confirmer'

cookie=sympa_session=78533451793110
listName="foo"
sleepTime=2

emails="foo5@labomedia.net foo3@labomedia.net foo6@labomedia.net"

TMP_OUTPUT_FILE="/tmp/framalistes_output.txt"

extractCsrfTokenFromPreviousResponse() {
	token=$( grep 'name="csrftoken"' $TMP_OUTPUT_FILE | head -1 | sed -re 's/.*value="([^"]+)".*/\1/' )
	#>&2 echo "found csrfToken: $token"
	echo "$token"
}

checkErrors() {
	if grep "Accès refusé" $TMP_OUTPUT_FILE
	then
		2&> echo "Erreur: problème d'accès probablement à cause du cookie ou du token CSRF !"
		exit 1
	fi
}

# Load list homepage
#curl -f -sS "https://framalistes.org/sympa/review/$listName" -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://framalistes.org/sympa' -H "Cookie: $cookie" > $TMP_OUTPUT_FILE
curl -f -sS "https://framalistes.org/sympa/review/$listName" --compressed -H "Cookie: $cookie" > $TMP_OUTPUT_FILE
checkErrors

csrfToken="$( extractCsrfTokenFromPreviousResponse )"
echo "list homepage csrfToken: $csrfToken"

for email in $emails
do
	echo "Adding email $email ..."
	sleep $sleepTime

	# Add email
	curl -f -sS -X POST 'https://framalistes.org/sympa' -H 'Content-Type: application/x-www-form-urlencoded' -H "Cookie: $cookie" -H 'Upgrade-Insecure-Requests: 1' -H 'TE: Trailers' --data "csrftoken=$csrfToken&previous_action=review&list=$listName&action=add&email=$email&action_add=Ajouter" > $TMP_OUTPUT_FILE
	checkErrors

	confirmCsrfToken="$( extractCsrfTokenFromPreviousResponse )"
	echo "confirm csrfToken: $confirmCsrfToken"

	sleep $sleepTime
	# Confirm
	curl -f -sS -X POST 'https://framalistes.org/sympa' -H 'Content-Type: application/x-www-form-urlencoded' -H "Cookie: $cookie" -H 'Upgrade-Insecure-Requests: 1' --data "csrftoken=$confirmCsrfToken&email=$email&action=add&list=$listName&previous_action=&response_action_confirm=Confirmer" > $TMP_OUTPUT_FILE
	checkErrors

	echo "Email $email added."
done
