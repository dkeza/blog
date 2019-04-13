cd themes/dkeza-hyde
git add -A
git commit -m "new template sources"
git push

cd ../..
git add -A
git commit -m "new blog sources"
git push

hugo --cleanDestinationDir -d ../dkeza.github.io
cd ../dkeza.github.io
echo www.kezic.net > CNAME
git add -A
git commit -m "new generated pages"
git push
cd ../blog
