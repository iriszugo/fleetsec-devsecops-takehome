# PLAYBOOK DE CONTENCIÓN DE EMERGENCIA AWS CLI (INCIDENTE T+02:00)

## 1. Contención IAM de Emergencia
aws iam detach-user-policy --user-name svc-monitoring --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam put-user-policy --user-name svc-monitoring --policy-name DenyAllExplicit --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Deny","Action":"*","Resource":"*"}]}'

## 2. Aislamiento de Red EC2
aws ec2 modify-instance-attribute --instance-id i-0abc1234def56789 --groups sg-quarantine-isolation-id

## 3. Interrupción de Tarea Rogue en ECS Cluster
aws ecs stop-task --cluster fleetsec-prod-cluster --task arn:aws:ecs:us-east-1:123456789012:task/fleetsec-prod-cluster/abc123xyz

## 4. Preservación Forense EBS
aws ec2 create-snapshot --volume-id vol-0abc1234def56789 --description "Forensic Snapshot T+02:00"
