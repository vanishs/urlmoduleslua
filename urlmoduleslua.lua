return require("umd").define({
    "exports",
    "github.com/vanishs/lua-resty-tsort-release001/lib/resty/tsort"
}, function(exports, tsort)

    function exports.run(name, func)
        local m = urlmodules[name]
        m.exports[func]()
    end

    function exports.init()

        local unpack = table.unpack or unpack
        local graph = tsort.new()
        for name, m in pairs(urlmodules) do
            local isAdd = false
            for _, dep in ipairs(m.deps) do
                if dep ~= "exports" then
                    graph:add(dep, name)
                    isAdd = true
                end
            end

            if not isAdd then
                graph:add(name)
            end

        end

        local tmns, err = graph:sort()
        if err then
            print(err)
            return
        end

        for _, n in pairs(tmns) do
            local m = urlmodules[n]
            local rms = {}
            for _, dep in ipairs(m.deps) do
                if dep == "exports" then
                    table.insert(rms, m.exports)
                elseif dep == "require" then
                    table.insert(rms, require)
                else
                    table.insert(rms, urlmodules[dep].exports)
                end
            end
            m.callback(unpack(rms))
        end

    end

end)
