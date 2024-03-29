if test (count $argv) -eq 0
    echo "Usage: sealSecret secretName secretValue namespace"
    return 1
end

echo -n $argv[2] | \
kubectl create secret generic $argv[1] --dry-run=client --from-file=$argv[1]=(/dev/stdin) -o yaml -n $argv[3] | \
kubeseal -o yaml
