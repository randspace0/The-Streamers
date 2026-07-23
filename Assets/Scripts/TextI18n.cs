using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TextI18n : MonoBehaviour
{
    Mgl.I18n i18n = Mgl.I18n.Instance;
    [SerializeField]
    string keyI18n;

    void Start()
    {
        Refresh();
    }

    public void Refresh()
    {
        GetComponent<Text>().text = i18n.__(keyI18n);
    }
}
