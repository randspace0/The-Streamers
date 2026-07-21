using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LanguageSelectorUI : MonoBehaviour
{
    static string[] locales = new string[] { "en-US", "id-ID" };
    [SerializeField]
    Sprite[] flags;

    void Start()
    {
        UpdateButton();
    }

    public void UpdateButton()
    {
        var locale = Mgl.I18n.GetLocale();
        for (byte i = 0; i < locales.Length; ++i)
        {
            if (locale == locales[i])
            {
                GetComponent<Image>().sprite = flags[i];
                return;
            }
        }
    }

    public void ToggleLanguage()
    {
        var currentIdx = System.Array.IndexOf(locales, Mgl.I18n.GetLocale());
        var nextIdx = (currentIdx + 1) % locales.Length;
        Mgl.I18n.SetLocale(locales[nextIdx]);

        UpdateButton();
        foreach (var text in FindObjectsOfType<TextI18n>())
        {
            text.Refresh();
        }
    }
}
