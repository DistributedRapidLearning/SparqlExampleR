del Algorithm.zip
del Signed.ec

cd site
Rscript createLibs.r

cd ..\

VarianFileSignerMaastro.exe %~dp0\master %~dp0\site %1

rmdir /S /Q site\libs