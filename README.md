# moon-warehouse

Preview - https://youtu.be/BR7JHsy82FY

<p> Moon Warehouse is a feature-rich warehouse system designed for QBCore, a popular framework for FiveM servers. This script enhances the gameplay experience by introducing the concept of warehouses, where players can store their items and manage their inventory efficiently. </p>

# Features

1) 16 PreBuilt Warehouses: Moon Warehouse comes with 16 pre-built warehouse locations, making it easy for players to choose a storage facility that suits their needs.

Lease System: Players can own a warehouse for a period of 7 days. After this period, they must renew their lease to continue using the warehouse.

Automatic Lease Expiry: If players fail to renew their lease, the script will automatically delete the warehouse, ensuring the map isn't cluttered with abandoned warehouses.

Warehouse Upgrades: Players have the option to upgrade their warehouse stash capacity, allowing them to store up to 5000 kilograms of items. They can also expand their warehouse slots, providing space for up to 110 items.

Easy Warehouse Addition: Adding a new warehouse is hassle-free. Simply add coordinates in the configuration file, and the script will automatically execute the SQL necessary to create it.

Warehouse Removal: Removing a warehouse is just as straightforward. Delete the coordinates from the configuration, and the warehouse will be removed from the map.

Shared Stashes: Warehouses have shared stashes, meaning that if a player forgets to renew their lease and their warehouse is deleted, a new owner can access, remove, and use the items left behind by the previous owner.

Admin Management: Administrators have the power to manage warehouses by using the /pullwarehousestash [warehouseid] command to access the contents of a specific warehouse.

Customization: You can easily customize the default price, stash size, and stash slots through SQL to fit the needs of your server.

# Dependencies

ox_lib: Moon Warehouse relies on the ox_lib library.
# Installation

Execute the SQL query below to set up the necessary database table:
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
ENGINE=InnoDB;
```
That's it! Moon Warehouse is now ready to elevate the storage and inventory management experience for players on your FiveM server.

Enjoy the script and provide feedback on the Script Support Discord if needed.
Discord - https://discord.gg/n9eSC4Zb
