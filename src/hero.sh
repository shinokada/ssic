fn_hero() {
    
    # clone heroicons from github
    cd "${CURRENTDIR}/heroicons" || exit 1
    git clone "${GITHEROURL}" || {
        echo "not able to clone"
        exit 1
    }

    # copy optimized from the cloned dir to heroicons dir
    mv "${CURRENTDIR}/heroicons/optimized" "${CURRENTDIR}/heroicons"

    # create a file icon-names.txt with names without svelte
    cd "${CURRENTDIR}/heroicons/outline" || exit
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Icon/' -- *.svg  && ls > icon-names.txt

    # Add , after each line in icon-names.txt
    sed -i 's/$/,/' icon-names.txt

    # in heroicons/outline and heroicons/solid rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/Icon.svelte/' -- *.svg  


    #  modify contents of all file by adding
    # 1. replace viewBox="0 0 20 20" to {viewBox} for solid and
    # viewBox="0 0 24 24" to {viewBox} for outline
    sed -i 's/viewBox="0 0 24 24"/{viewBox}/' ./*.*

    # 2. & 3. insert script tag at the beginning for solid and insert class={className}
    sed -i '1s/^/<script>export let className="h-6 w-6"; viewBox="0 0 20 20"<\/script>/' ./*.* && sed -i 's/fill/class={className} &/' ./*.*

    # for outline insert script tag at the beginning for solid  and insert class={className}
    sed -i '1s/^/<script>export let className="h-6 w-6"; export let viewBox="0 0 24 24";<\/script>/' ./*.* && sed -i 's/fill/class={className} &/' ./*.*

    # ls file names to each index.txt
    ls "*.svelte" > index.txt
    # modify index.js file
    # for outline
    sed -i "s:\(.*\)\.svelte:import \1 from './heroicons/outline/&':" index.txt
    # for solid
    sed -i "s:\(.*\)\.svelte:import \1 from './heroicons/solid/&':" index.txt

    # Adding export
    # 1 insert export {} to index.js, 2 insert icon-names to index.js after export {
    echo 'export {' >> index.txt && cat index.txt icon-names.txt > index.js && echo '}' >> index.js
    
    # copy index.js to outline and solid dir
    cp "${CURRENTDIR}/heroicons/index.js" "${CURRENTDIR}/heroicons/outline" "${CURRENTDIR}/heroicons/solid"
    # clean up
    rm icon-names.txt index.txt
    rm -rf "${CURRENTDIR}/heroicons/heroicons-master"
    
    echo "Done."
}
