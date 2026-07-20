using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    [SerializeField]
    GameObject thingsAboveGroundObj;
    [SerializeField]
    GameObject upperViewObj;
    [SerializeField]
    GameObject textScoreObj;
    [SerializeField]
    GameObject textResultScoreObj;
    [SerializeField]
    float levelDurationSeconds = 120.0f;
    [SerializeField]
    float winMoodThreshold = 50.0f;
    List<Building> buildings = new List<Building>();
    float timeLeft;
    bool gameEnded = false;

    void Start()
    {
        Time.timeScale = 1.0f;
        PopulateBuildings();
        timeLeft = levelDurationSeconds;
        textResultScoreObj.SetActive(false);
    }

    void Update()
    {
        if (gameEnded)
        {
            return;
        }

        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (upperViewObj.GetComponent<Transform>().transform.position.x < 10.0f)
            {
                upperViewObj.GetComponent<Transform>().transform.position = new Vector3(1000.0f, 0.0f, 0.0f);
            }
            else
            {
                upperViewObj.GetComponent<Transform>().transform.position = new Vector3(0.0f, 0.0f, 0.0f);
            }
        }

        timeLeft -= Time.deltaTime;
        textScoreObj.GetComponent<Text>().text = string.Format("{0:0.0}%  {1:0}s", MeanScore(), Mathf.Max(timeLeft, 0.0f));

        if (timeLeft <= 0.0f)
        {
            EndGame();
        }
    }

    void EndGame()
    {
        gameEnded = true;
        // ponytail: global pause via timeScale, per-system pause (pipes/buildings) if partial-freeze is ever needed
        Time.timeScale = 0.0f;

        bool won = MeanScore() >= winMoodThreshold;
        textResultScoreObj.SetActive(true);
        textResultScoreObj.GetComponent<Text>().text = won
            ? string.Format("You Win!\nFinal Score: {0:0.0}%", MeanScore())
            : string.Format("Game Over\nFinal Score: {0:0.0}%", MeanScore());
    }

    float MeanScore()
    {
        return TotalScore() / (float)buildings.Count;
    }

    void PopulateBuildings()
    {
        var buildingComponents = thingsAboveGroundObj.GetComponentsInChildren<Building>();
        foreach (var building in buildingComponents)
        {
            if (building != null)
            {
                buildings.Add(building);
            }
        }
    }

    float TotalScore()
    {
        float moodTotal = 0;
        foreach (var building in buildings)
        {
            moodTotal += building.moodAmount;
        }

        return moodTotal;
    }

    public void BackToLevelSelector()
    {
        Time.timeScale = 1.0f;
        SceneManager.LoadScene("LevelSelectorScene", LoadSceneMode.Single);
    }
}
