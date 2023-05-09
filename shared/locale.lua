Locales = {}

function _U(string, ...)
    if Config.Locale == nil then
        print('Cannot found in config Locale')
        return 'not_found_config'
    end

    if Locales[Config.Locale] == nil then
        print('Cannot found locale %s', Config.Locale)
        return 'not_found_locale'
    end

    if Locales[Config.Locale][string] == nil then
        print('Cannot found locale string %s in locale %s', string, Config.Locale)
        return string
    end

    return string.format(Locales[Config.Locale][string], ...)
end
