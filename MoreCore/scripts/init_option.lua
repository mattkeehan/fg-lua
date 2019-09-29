-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

            function onInit()
                OptionsManager.registerOption2("INAD", true, "option_header_combattracker", "option_label_INAD", "option_entry_cycler", 
                     { labels = "option_val_asc", values = "asc", baselabel = "option_val_desc", baseval = "desc", default = "desc" })
                OptionsManager.registerCallback("INAD", onOptionUpdate)
                onOptionUpdate()
            end
            function onOptionUpdate()
                if OptionsManager.isOption("INAD", "desc") then
                    CombatManager.setCustomSort(sortfuncDescending)
                    EffectManager.setInitAscending(false)
                else
                    CombatManager.setCustomSort(sortfuncAscending)
                    EffectManager.setInitAscending(true)
                end
            end
            function sortfuncDescending(...)
                return CombatManager.sortfuncStandard(...)
            end
            function sortfuncAscending(...)
                return not CombatManager.sortfuncStandard(...)
            end
