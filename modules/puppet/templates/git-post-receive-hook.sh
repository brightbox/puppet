#!/bin/bash

set -e

mkdir -p /etc/puppet/tmp

# deploy $branch $puppet_environment
function deploy {
		BRANCH=$1
		PENV=$2
		if git show-ref $BRANCH >/dev/null ; then 
				DEST=`mktemp -d --tmpdir=/etc/puppet/tmp`
				OLD=`mktemp -d --tmpdir=/etc/puppet/tmp`
				echo "Deploying git branch $BRANCH to puppet environment $PENV"
				git archive --format=tar $1 | tar -C $DEST -x
				mv /etc/puppet/$PENV $OLD
				mv $DEST /etc/puppet/$PENV
				rm -rf $OLD
		else
				echo "Skipping deployment of $PENV as there is no branch named $BRANCH"
		fi
}

deploy master staging 
deploy production production


