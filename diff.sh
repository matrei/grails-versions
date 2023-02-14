#!/bin/bash
git config user.name github-actions
git config user.email github-actions@github.com

export SDKMAN_DIR="$HOME/.sdkman" && source "$HOME/.sdkman/bin/sdkman-init.sh"
export CURRENT_DIR=`pwd` 
for version in $(cat versions.txt)
do
    echo "Processing $version"
    sdk install grails $version
    sdk use grails $version
    grails create-app versions
    cd versions
    ./gradlew -v
    ./gradlew --no-daemon dependencyManagement > dependencies.txt
    ls -l
    cd $CURRENT_DIR
    pwd
    echo "Performing git gymnastics"
    git add versions
    git commit -a -m $version
    git push origin :refs/tags/$version
    git tag $version
    rm -rf versions
    sdk uninstall grails $version
    sdk flush archives
    df -h .
done

git commit -a -m "Cleanup"
git push origin master -f
git push origin --tags -f
