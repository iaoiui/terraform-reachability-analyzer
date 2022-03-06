# terraform-reachability-analyzer
AWS Reachability Analyzer example for terraform

# Quickstart

```
terraform apply -auto-approve
```

```
❯ LB_DNS="http://"`terraform output -raw alb_dns`
❯ curl $LB_DNS   
<pre>
Hello World


                                       ##         .
                                 ## ## ##        ==
                              ## ## ## ## ##    ===
                           /""""""""""""""""\___/ ===
                      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
                           \______ o          _,/
                            \      \       _,'
                             `'--.._\..--''
</pre>

```