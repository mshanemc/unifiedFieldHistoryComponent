sfdx force:org:create -f config/project-scratch-def.json -d 1 -s --wait 60
sfdx force:source:push

sfdx force:data:tree:import -p data/Account-Opportunity-plan.json
sfdx force:data:record:update -s Opportunity -w "Name='Test Oppty'" -v "Amount=102"
sfdx force:data:record:update -s Opportunity -w "Name='Test Oppty'" -v "StageName='Needs Analysis'"
sfdx force:data:record:update -s Opportunity -w "Name='Test Oppty'" -v "Description='My Biggest Deal Ever!!'"
sfdx force:data:record:update -s Opportunity -w "Name='Test Oppty'" -v "CloseDate=2019-01-05"

sfdx force:org:open