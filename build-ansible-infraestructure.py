#!/usr/bin/python3
import json
import argparse


class InventoryParser(object):
    def __init__(self, inventory_location: str):
        self.inventory_location = inventory_location
        with open(inventory_location, 'r') as inventory_file:
            self.inventory = json.load(inventory_file)
            inventory_file.close()

    def _save_inventory(self):
        with open(self.inventory_location, 'w') as inventory_file:
            json.dump(self.inventory, inventory_file, indent=4)
            inventory_file.close()

    def _check_if_group_exists(self, group_name: str) -> bool:
        if self.inventory.get(group_name):
            return True
        return False

    def _create_group(self, group_name):
        self.inventory[group_name] = {
            "hosts": [],
            "vars": {}
        }

    def add_new_host(self, new_host_address: str):
        host_list = self.inventory["new"]["hosts"]
        if new_host_address not in host_list:
            host_list.append(new_host_address)
        self.inventory["new"]["hosts"] = host_list
        self._save_inventory()

    def move_host_to_other_group(self, host: str, original_group: str, final_group: str):
        original_group_hosts = self.inventory.get(original_group).get("hosts")
        final_group_hosts = []
        if host in original_group_hosts:
            final_group_hosts.append(host)
            original_group_hosts.remove(host)
        if self._check_if_group_exists(final_group):
            self.inventory[final_group]["hosts"] = self.inventory.get(final_group).get("hosts") + final_group_hosts
        else:
            self._create_group(final_group)
            self.inventory[final_group]["hosts"] = self.inventory[final_group]["hosts"] + final_group_hosts
        self._save_inventory()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    required = parser.add_argument_group('required arguments')
    optional = parser.add_argument_group('required arguments')
    optional.add_argument("--newHost", action='store_true', help="Add new host to group New for initial configuration")
    optional.add_argument("--moveHost", action='store_true', help="Move host from one group to another")
    required.add_argument("--inventory", action='store', help="File Inventory loctaion, inventory.json file")
    optional.add_argument("--host", action='store')
    optional.add_argument("--originalGroup", action='store', default=argparse.SUPPRESS)
    optional.add_argument("--finalGroup", action='store', default=argparse.SUPPRESS)

    arguments = parser.parse_args()
    inventory_parser = InventoryParser(arguments.inventory)
    if arguments.newHost:
        inventory_parser.add_new_host(arguments.host)
    if arguments.moveHost:
        inventory_parser.move_host_to_other_group(arguments.host, arguments.originalGroup, arguments.finalGroup)
