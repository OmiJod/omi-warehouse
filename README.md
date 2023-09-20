# moon-warehouse
Warehouse System for QBCore


1)16 PreBuilt Warehouses

2)Players Can Own One Warehouse for 7 Days After that they have to renew it

3)If players Fail to renew the lease the Script Will Automatically Delete it

4)Players can Upgrade there warehouse stash up to 5000 Kgs

5)Players can Upgrade there warehouse slots up to 110

6)To Add a New Ware house all you have to do is add coords in the config the script will automaticall execute the sql

7)To remove a warehouse just remove the coords from the config

8)Ware house has shared stashes that means if some player forgets to renew the ware house and it gets deleted and some other player buys that ware house, all the items of the

previous owner can be access and removed and used by the new owner

9)Admins can pull stash of a warehouse by doing /pullwarehousestash [warehouseid]

10) Default price which is 10k can be changed thhrough SQL same with stashsize and stash slots


dependancy is ox_lib

Installation 
1) Execute the below table and you are done

```sql
CREATE TABLE `warehouses` (
	`location` INT(11) NOT NULL,
	`owned` INT(11) NULL DEFAULT NULL,
	`owner` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`stashsize` INT(11) NULL DEFAULT NULL,
	`slots` INT(11) NULL DEFAULT NULL,
	`price` INT(11) NULL DEFAULT NULL,
	`date_purchased` DATE NULL DEFAULT NULL,
	PRIMARY KEY (`location`) USING BTREE
)
COLLATE='utf8mb3_general_ci'
ENGINE=InnoDB
;
