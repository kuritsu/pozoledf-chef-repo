# Chef Infra Server

This server gets configured by the `cookbooks/pozoledf-chef-server` recipe, but for a
clean install should be used the `scripts/install-chef-server.sh` script.

It installs and configures the following software:

- [Chef Automate](https://docs.chef.io/automate/infra_server/), which in chain installs also:
  - [Chef Infra Server](https://docs.chef.io/server/)
  - [Chef Habitat Builder](https://docs.chef.io/habitat/builder_overview/)

After completing a successfull installation, this [chef repo](https://docs.chef.io/chef_repo/) 
will be automatically synced/uploaded to the Chef server, though you can change that behavior
in the [cookbooks/pozoledf-chef-server/recipes/default.rb](../cookbooks/pozoledf-chef-server/recipes/default.rb) recipe and the
[cookbooks/pozoledf-chef-server/files/repo-sync.sh](../cookbooks/pozoledf-chef-server/files/repo-sync.sh) script. The following info will be synchronized:

- `cookbooks` directory.
- `environments` directory. See [here](#Habitat_channels) for more details on this folder.
- `policyfiles` directory. `chef update`, `chef push` will be performed to keep local
  versions of the 3rd party cookbooks required by the cookbooks of this repo.
- `roles` directory.

Note that you can check the automated sync log at `/var/log/chef-repo-sync.log`.

## Habitat channels

Each environment inside the `environments` directory correspond to a [Chef Habitat channel](https://docs.chef.io/habitat/pkg_promote/#continuous-deployment-using-channels), meaning
that when configured, the environments also will be synced in Habitat Builder (installed
in this node).

To enable environment synchronization (aka channel creation), follow the next steps:
- Enter the Habitat Builder UI (which you can find after you open the Chef Automate UI,
  then go to Applications on the main menu, then click on the Habitat Builder link on the left menu)
- Sign in with your Automate credentials.
- Click on the Avatar menu (icon on the top right) and click Profile.
- There you can update some of the profile settings, and then click on the 
  [Generate token button](https://docs.chef.io/habitat/builder_profile/#create-a-personal-access-token).
  Save the token generated in a safe place, as you will use it later.
- Connect to the Chef Server, then run `hab cli setup` as root.
  - Configure an on-premise builder instance, set the URL to
    `https://chef-server/bldr/v1/`, replace `chef-server` with
    the same value you used for `CHEF_SERVER_HOSTNAME` after you ran
    the `install-chef-server.sh` script.
  - Set a default origin, with the same `ORG_NAME` you used on the
    `install-chef-server.sh` script.
  - Choose `yes` to setup a default Builder personal token, set it to the
    token you generated earlier from the Builder page.
  - You can choose `no` to set a Habitat Supervisor control gateway secret.

This should have created a file `/hab/etc/cli.toml`. Now, every 5 minutes
(default setting in cron), as the [repo-sync](../cookbooks/pozoledf-chef-server/files/repo-sync.sh) script runs, when it detects that the `/hab/etc/cli.toml` file
exists, it will:
- create and generate public and private keys for the origin named after the organization. 
- get all environments (`.json` files under the `environments` dir), and use
the file name as the channel name (without the `.json` extension) and will create the
channel on Habitat if it doesn't exist.
