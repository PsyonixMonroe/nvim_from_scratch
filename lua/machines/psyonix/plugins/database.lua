return {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
        { 'tpope/vim-dadbod', lazy = true },
    },
    cmd = {
        'DBUI',
        'DBUIToggle',
        'DBUIAddConnection',
        'DBUIFindBuffer',
    },
    init = function()
        -- get mysql password from vault
        local get_secret_value = function()
            return vim.system({ 'get_mysql_from_vault' }):wait().stdout
        end

        -- build conn string
        local get_remote_mysql = function(secret, local_port)
            return 'mysql://matt.monroe:' .. secret .. '@127.0.0.1:' .. local_port
        end

        -- Your DBUI configuration
        vim.g.db_ui_use_nerd_fonts = 1
        local secret = get_secret_value()
        vim.g.dbs = {
            { name = 'PsyNet-Local',           url = 'mysql://root:password@127.0.0.1:3306' },
            { name = 'BC2Backend-Local',       url = 'mysql://root:password@127.0.0.1:3308' },
            { name = 'CoachingEngine-Local',   url = 'mysql://root:password@127.0.0.1:6033' },
            { name = 'BC2Backend-IntTest',     url = 'mysql://root:password@127.0.0.1:3307' },
            { name = 'CoachingEngine-IntTest', url = 'mysql://root:password@127.0.0.1:7033' },
            { name = 'RLPT',                   url = get_remote_mysql(secret, 3400) },

            { name = 'RLPS-Main',              url = get_remote_mysql(secret, 3410) },
            { name = 'RLPS-Tournament',        url = get_remote_mysql(secret, 3411) },
            { name = 'RLPS-Progression',       url = get_remote_mysql(secret, 3412) },
            { name = 'RLPS-Match',             url = get_remote_mysql(secret, 3413) },
            { name = 'RLPS-Matchmaking',       url = get_remote_mysql(secret, 3414) },
            { name = 'RLPS-Leaderboard',       url = get_remote_mysql(secret, 3415) },
            { name = 'RLPS-Gameserver',        url = get_remote_mysql(secret, 3416) },
            { name = 'RLPS-Skill',             url = get_remote_mysql(secret, 3417) },
            { name = 'RLPS-Challenge',         url = get_remote_mysql(secret, 3418) },
            { name = 'RLPS-Savedata',          url = get_remote_mysql(secret, 3419) },

            { name = 'RLPS-Cert-Main',         url = get_remote_mysql(secret, 3420) },
            { name = 'RLPS-Cert-Tournament',   url = get_remote_mysql(secret, 3421) },
            { name = 'RLPS-Cert-Progression',  url = get_remote_mysql(secret, 3422) },
            { name = 'RLPS-Cert-Match',        url = get_remote_mysql(secret, 3423) },
            { name = 'RLPS-Cert-Matchmaking',  url = get_remote_mysql(secret, 3424) },
            { name = 'RLPS-Cert-Leaderboard',  url = get_remote_mysql(secret, 3425) },
            { name = 'RLPS-Cert-Gameserver',   url = get_remote_mysql(secret, 3426) },
            { name = 'RLPS-Cert-Skill',        url = get_remote_mysql(secret, 3427) },
            { name = 'RLPS-Cert-Challenge',    url = get_remote_mysql(secret, 3428) },
            { name = 'RLPS-Cert-Savedata',     url = get_remote_mysql(secret, 3429) },

            { name = 'RLPP-Main',              url = get_remote_mysql(secret, 3430) },
            { name = 'RLPP-Tournament',        url = get_remote_mysql(secret, 3431) },
            { name = 'RLPP-Progression',       url = get_remote_mysql(secret, 3432) },
            { name = 'RLPP-Match',             url = get_remote_mysql(secret, 3433) },
            { name = 'RLPP-Matchmaking',       url = get_remote_mysql(secret, 3434) },
            { name = 'RLPP-Leaderboard',       url = get_remote_mysql(secret, 3435) },
            { name = 'RLPP-Gameserver',        url = get_remote_mysql(secret, 3436) },
            { name = 'RLPP-Skill',             url = get_remote_mysql(secret, 3437) },
            { name = 'RLPP-Challenge',         url = get_remote_mysql(secret, 3438) },
            { name = 'RLPP-Savedata',          url = get_remote_mysql(secret, 3439) },

            { name = 'RLMT',                   url = get_remote_mysql(secret, 3440) },

            { name = 'RLMS-Main',              url = get_remote_mysql(secret, 3450) },
            { name = 'RLMS-Progression',       url = get_remote_mysql(secret, 3452) },
            { name = 'RLMS-Match',             url = get_remote_mysql(secret, 3453) },
            { name = 'RLMS-Matchmaking',       url = get_remote_mysql(secret, 3454) },
            { name = 'RLMS-Gameserver',        url = get_remote_mysql(secret, 3456) },
            { name = 'RLMS-Skill',             url = get_remote_mysql(secret, 3457) },
            { name = 'RLMS-Challenge',         url = get_remote_mysql(secret, 3458) },

            { name = 'RLMP-Main',              url = get_remote_mysql(secret, 3450) },
            { name = 'RLMP-Progression',       url = get_remote_mysql(secret, 3452) },
            { name = 'RLMP-Match',             url = get_remote_mysql(secret, 3453) },
            { name = 'RLMP-Matchmaking',       url = get_remote_mysql(secret, 3454) },
            { name = 'RLMP-Gameserver',        url = get_remote_mysql(secret, 3456) },
            { name = 'RLMP-Skill',             url = get_remote_mysql(secret, 3457) },
            { name = 'RLMP-Challenge',         url = get_remote_mysql(secret, 3458) },
        }
    end,
}
