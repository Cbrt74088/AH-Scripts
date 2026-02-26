#Requires AutoHotkey v2.0
;#Persistant true
;#Include Lib.ahk
;#NoTrayIcon
#SingleInstance Force ;Force Ignore Prompt Off

;CoordMode ;ToolTip|Pixel|Mouse|Caret|Menu, Screen|Window|Client
SetTitleMatchMode 1 ; 1:must start with 2: can contain anywhere 3: must match exactly


class Ini
{
    class Doc
    {
        __New(path)
        {
            this._path := path
        }

        __Item[section] => Ini.Section(this._path, section)

        Sections()
        {
            return Ini._Sections(this._path)
        }

        KeyValues(section)
        {
            return Ini._KeyValues(this._path, section)
        }

        Read(section, key)
        {
            return Ini._Read(this._path, section, key)
        }

        Write(section, key, value)
        {
            Ini._Write(this._path, section, key, value)
        }

        DeleteKey(section, key)
        {
            return Ini._DeleteKey(this._path, section, key)
        }

        DeleteSection(section)
        {
            return Ini._DeleteSection(this._path, section)
        }

    }


    class Section
    {
        __New(path, section)
        {
            this._path := path
            this._section := section
        }

        KeyValues()
        {
            return Ini._KeyValues(this._path, this._section)
        }

        Read(key)
        {
            return Ini._Read(this._path, this._section, key)
        }

        Write(key, value)
        {
            Ini._Write(this._path, this._section, key, value)
        }

        DeleteKey(key)
        {
            return Ini._DeleteKey(this._path, this._section, key)
        }

        Delete()
        {
            return Ini._DeleteSection(this._path, this._section)
        }

    }


    static _Sections(path)
    {
        return IniRead(path)
    }

    static _KeyValues(path, section)
    {
        return IniRead(path, section)
    }

    static _Read(path, section, key)
    {
        try {
            return IniRead(path, section, key)
        } catch {
            return ""
        }
    }

    static _Write(path, section, key, value)
    {
        IniWrite value, path, section, key
    }


    static _DeleteKey(path, section, key)
    {
        try {
            IniDelete path, section, key
            return True
        } catch {
            return False
        }
    }


    static _DeleteSection(path, section)
    {
        try {
            IniDelete path, section
            return True
        } catch {
            return False
        }
    }

}


