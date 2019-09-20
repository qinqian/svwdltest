for i in cromwell-executions/manta/9b112f3b-bee3-4121-927d-f9b8004951c8/call-manta_hg38/shard-*/execution; do 

if [ ! -s  ${i}/stdout ];then
   echo $i
   tail ${i}/stdout
fi

#bash ${i}/script
#bash ${i}/script.submit
done


