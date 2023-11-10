local handle = io.popen("xplr --version | awk '{print $2}'")
version = handle:read('*line')
handle:close()

local home = os.getenv("HOME")
local xpm_path = home .. "/.config/xplr/plugins/xpm.xplr"
local xpm_url = "https://github.com/dtomvan/xpm.xplr"

package.path = package.path
    .. ";"
    .. xpm_path
    .. "/?.lua;"
    .. xpm_path
    .. "/?/init.lua"

os.execute(
    string.format(
        "[ -e '%s' ] || git clone '%s' '%s'",
        xpm_path,
        xpm_url,
        xpm_path
    )
)

require("xpm").setup({
    plugins = {
        'dtomvan/xpm.xplr',
        'prncss-xyz/icons.xplr',
        {
            'dtomvan/extra-icons.xplr',
            after = function()
                xplr.config.general.table.row.cols[2] = { format = "custom.icons_dtomvan_col_1" }
            end
        },
    },
    auto_install = true,
    auto_cleanup = true,
})
--
