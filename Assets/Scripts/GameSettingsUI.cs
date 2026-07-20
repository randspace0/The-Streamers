using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameSettingsUI : MonoBehaviour
{
    [SerializeField]
    Sprite[] enableVolumeButtonSprites;
    [SerializeField]
    GameObject enableVolumeButtonObj;
    Image enableVolumeButtonImage;

    [SerializeField]
    GameObject volumeSliderObj;
    Slider volumeSliderSlider;

    void Start()
    {
        enableVolumeButtonImage = enableVolumeButtonObj
            .GetComponent<Button>()
            .GetComponent<Image>();
        volumeSliderSlider = volumeSliderObj
            .GetComponent<Slider>();
        UpdateEnableSoundButton();
        UpdateVolumeSliderButton();
    }

    public void SetVolume(System.Single volume)
    {
        GameSettings.Instance.volume = volume;
    }

    public void ToggleSound()
    {
        SetSoundOn(!GameSettings.Instance.isSoundOn);
    }

    public void SetSoundOn(bool isOn)
    {
        GameSettings.Instance.isSoundOn = isOn;
        UpdateEnableSoundButton();
    }

    public void UpdateVolumeSliderButton()
    {
        volumeSliderSlider.value = GameSettings.Instance.volume;
    }

    public void UpdateEnableSoundButton()
    {
        enableVolumeButtonImage.sprite = enableVolumeButtonSprites[GameSettings.Instance.isSoundOn? 0 : 1];
    }
}
