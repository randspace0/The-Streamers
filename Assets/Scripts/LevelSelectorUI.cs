using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LevelSelectorUI : MonoBehaviour
{
    public void OnClickLevel(int level)
    {
        // Should we do it async?
        // TODO
        SceneManager.LoadScene($"Level{level}", LoadSceneMode.Single);
    }

    public void OnClickBackToMainMenu()
    {
        SceneManager.LoadScene("MainMenuScene");
    }
}
