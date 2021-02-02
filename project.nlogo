breed [cntry1 migrant1]
breed [cntry2 migrant2]
cntry1-own [cntry1-intellect
  cntry1-age
  cntry1-migrate-prob
  cntry1-new]

cntry2-own [cntry2-intellect
  cntry2-age
  cntry2-migrate-prob
  cntry2-new]

globals [
  weather
  cntry1-birth
  cntry2-birth
  age
]

;--------------------------------------------------------------;
to setup
  clear-all

  ask patches with [pxcor = 0] [set pcolor yellow]   ; to represent the border


  create-people
  initialize-turtles cntry1 cntry2
  reset-ticks
end

;--------------------------------------------------------------;
to create-people

  create-cntry1 country1-population [
    set xcor 1 + random 12
    set ycor random 24
    set color green
    set size 2
    set shape "person"
    set cntry1-migrate-prob 0
    set cntry1-age random 100 ;ages are randomly assigned
  ]

  create-cntry2 country2-population [
    set xcor -12 + random 12
    set ycor 0 + random 24
    set color red
    set size 2
    set shape "person"
    set cntry2-migrate-prob 0
    set cntry2-age random 100
  ]

   ; 0.05 + birthrate
    ; birthrate is higher where there is better quality of life (assumption)

   ifelse quality-life = "country1"
    [set cntry1-birth (birthrate + 0.05)
     set cntry2-birth birthrate]

    [set cntry1-birth birthrate
     set cntry2-birth (birthrate + 0.05)]


end

;--------------------------------------------------------------;
to initialize-turtles [cntry1-turtles cntry2-turtles]

  ask cntry1-turtles[
    ; family
    ; any agents within radius of 1
    create-links-to other cntry1 in-radius 1
    ask my-links [hide-link]]

   ;  initialize college grads
  ask n-of (count cntry1-turtles * country1-pct-college-population) cntry1-turtles
    [set cntry1-intellect 1]



  ask cntry2-turtles [
    create-links-to other cntry2 in-radius 1
    ask my-links [hide-link]]

   ask n-of (count cntry2-turtles * country2-pct-college-population) cntry2-turtles
    [set cntry2-intellect 1]
end

;---------------------------------------------------------------;
;---------------------------------------------------------------;
to reproduce
 ask n-of (count cntry1 * cntry1-birth) cntry1
    [set cntry1-new 0
     hatch 1
      [set xcor 1 + random 12
        set ycor 0 + random 24
        set color green
        set cntry1-new 1
        set cntry1-migrate-prob 0
        set cntry1-age random 100]]


 ask n-of (count cntry2 * cntry2-birth) cntry2
    [set cntry2-new 0
     hatch 1
      [set xcor -12 + random 12
        set ycor 0 + random 24
        set color red
        set cntry2-age random 100 ;the age of the newborn is also randomly assign, a newborn can be 80 of age (assumption)
        set cntry2-migrate-prob 0
        set cntry2-new 1]]

  ; assign family and education level to the new agents
  initialize-turtles cntry1 with [cntry1-new = 1] cntry2 with [cntry2-new = 1]

end

to death

  ; die at age 80
  ask cntry1 with [cntry1-age >= 80]
  [die]

  ask cntry2 with [cntry2-age >= 80]
  [die]
end

;-----------------------------------------------------------;


to update-prob

  ; agent aged between 18 and 50 will be more likely to move to where there is better opportunities and education
  ask cntry1 with [cntry1-intellect = 1 and cntry1-age < 50 and cntry1-age > 18][
    if quality-education = "country2"[
      set cntry1-migrate-prob cntry1-migrate-prob + 0.11]
  ]

  ; 44% chance that anyone will migrate to where there is better quality of life
  ; 50% of the population
  ask cntry1[
    let ran random 101
    if quality-life = "country2"[
      if ran < 50
        [set cntry1-migrate-prob cntry1-migrate-prob + 0.54]]]



  ask cntry2 with [cntry2-intellect = 1 and cntry2-age < 50 and cntry2-age > 18][
    if quality-education = "country1"[
      set cntry2-migrate-prob cntry2-migrate-prob + 0.11]
  ]

  ask cntry2[
    let ran random 101
    if quality-life = "country1"[
      if ran < 50[
        set cntry2-migrate-prob cntry2-migrate-prob + 0.54]]]

end

;-------------------------------------------------------------;

; climate: natural disaster will also have an affect on migration
; 5%
to weather-prob

  ; this is decided randomly
  ; switch
  ifelse weather = "Country 1"
  [ask cntry1[
      set cntry1-migrate-prob cntry1-migrate-prob + 0.05]
  ]
  [ ask cntry2[
      set cntry2-migrate-prob cntry2-migrate-prob + 0.05]
  ]
end

;--------------------------------------------------------------;

; move agents
to update-turtles
  ask cntry1 [
    set cntry1-new 0
    if cntry1-migrate-prob > threshold [

      ; Relatives of the migrant are more likely to follow
      ; 33%
      if count out-link-neighbors > 0[
        ask out-link-neighbors with [breed = cntry1][
        set cntry1-migrate-prob cntry1-migrate-prob + 0.33]
      ]

      set age cntry1-age
      ; becomes citizen of country 2
      set breed cntry2
      set xcor -12 + random 12
      set ycor 0 + random 24
      set color green
      set shape "person"
      ; reset to 0
      set cntry2-migrate-prob 0
      set cntry2-age age]

    ifelse show-connections
    [set label count out-link-neighbors]
    [set label ""]
  ]
;-----------
  ask cntry2 [
    set cntry2-new 0
    if cntry2-migrate-prob > threshold [

      if count out-link-neighbors > 0[
        ask out-link-neighbors with [breed = cntry2] [
        set cntry2-migrate-prob cntry2-migrate-prob + 0.33]
      ]

      set age cntry2-age
      set breed cntry1
      set xcor 1 + random 12
      set ycor 0 + random 24
      set color red
      set shape "person"
      set cntry1-migrate-prob 0
      set cntry1-age age]

    ifelse show-connections
    [set label count out-link-neighbors]
    [set label ""]
  ]

end

;-----------------------------------------------------------;

to go
  update-prob
  update-turtles
  reproduce
  death

  if natural-disaster[
    let ran-weather random 101
    if ran-weather < 5 [
        let which random 101
         ifelse which < 50
            [set weather "Country 1"]
          [set weather "Country 2"]

        weather-prob
      output-print weather
  ]
  ]

  if count cntry1 > max-population
  [user-message ("Overpopulation in Country 1")]
  if count cntry2 > max-population
  [user-message ("Overpopulation in Country 2")]

;  let ran-weather random 101
;  ifelse ran-weather < 50
;  [set cntry1-weather 1]
;  [set cntry2-weather 1]

  tick
end

@#$#@#$#@
GRAPHICS-WINDOW
288
10
721
444
-1
-1
17.0
1
10
1
1
1
0
1
1
1
-12
12
-12
12
1
1
1
weeks
30.0

BUTTON
20
46
103
79
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
202
47
265
80
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
728
26
912
59
country1-population
country1-population
0
300
100.0
1
1
NIL
HORIZONTAL

SLIDER
990
25
1174
58
country2-population
country2-population
0
300
100.0
1
1
NIL
HORIZONTAL

SLIDER
728
73
984
106
country1-pct-college-population
country1-pct-college-population
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
989
72
1245
105
country2-pct-college-population
country2-pct-college-population
0
1
0.5
0.1
1
NIL
HORIZONTAL

PLOT
746
129
1186
370
Populations in Country 1 and 2
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Country 1" 1.0 0 -13840069 true "" "plot count cntry1"
"Country 2" 1.0 0 -2674135 true "" "plot count cntry2"

CHOOSER
0
100
138
145
quality-education
quality-education
"country1" "country2"
1

SLIDER
5
165
177
198
birthrate
birthrate
0
0.7
0.7
0.05
1
NIL
HORIZONTAL

CHOOSER
146
101
284
146
quality-life
quality-life
"country1" "country2"
1

TEXTBOX
573
453
723
478
Country 1
20
0.0
1

TEXTBOX
341
452
491
477
Country 2
20
0.0
1

PLOT
521
490
721
640
Immigrants in Country 1
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -14439633 true "" "plot count cntry1 with [color = red]"

PLOT
281
489
481
639
Immigrants in Country 2
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -5298144 true "" "plot count cntry2 with [color = green]"

SWITCH
1057
389
1214
422
natural-disaster
natural-disaster
0
1
-1000

SLIDER
2
206
174
239
max-population
max-population
0
5000
1800.0
100
1
NIL
HORIZONTAL

SWITCH
792
395
945
428
show-connections
show-connections
1
1
-1000

OUTPUT
1079
447
1192
484
13

TEXTBOX
1019
427
1325
478
Which country is having a natural disaster?
14
0.0
1

TEXTBOX
1056
493
1232
526
Note: Natural disasters happen 5% of the time and the country is picked at random
9
0.0
1

TEXTBOX
768
430
989
463
Shows how many relatives an immigrants has in their home country
9
0.0
1

SLIDER
2
295
174
328
threshold
threshold
0.6
0.9
0.9
0.1
1
NIL
HORIZONTAL

BUTTON
120
46
183
79
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
519
654
719
804
Age distribution in Country 1
NIL
NIL
0.0
80.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -14439633 true "" "set-histogram-num-bars 5 histogram [cntry1-age] of cntry1"

PLOT
280
655
480
805
Age Distribution in Country 2
NIL
NIL
0.0
80.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -5298144 true "" "set-histogram-num-bars 5 histogram [cntry2-age] of cntry2"

@#$#@#$#@
## WHAT IS IT?

“Migration” describes the movement of people from one region to another. Humans have been migrating all throughout history in search of more favorable conditions. Outside factors and disparities between two countries encourage the movement to where there perceived better opportunities. In fact, this behavior is also observed in most organizations where two systems are unequal to each other. The disparity between the systems causes agents to move from one region to another. This process continues until an equilibrium point is reached, indicating that there is no further observative change in movement due to equal and balanced forces. This theory also applies to human migration as it reaches a point where the resources of one country can no longer support its inhabitants. This is the period where citizens of that country start to delegate to prevent further immigration. This describes the 21st century as we are seeing a period of extraordinary mobility across country borders along with the passage of immigration laws and regulations. The proposed model attempts to simulate this behavior through the use of agent-based modelling. The simplification of the model from the actual world allows one to exclude confounding factors and explore the implications of the underlying entities. Through this model, we hope to contribute to the established knowledge of how factors affect population movements. The proposed model provides an experimental tool that allows for hypothesis and theory development that can help researchers gain more in-depth insights into the innerworkings and the driving forces of migration.  

## HOW IT WORKS

The model simulates the flow between two populations as conditions are changed by the user. The fluctuations of the two populations involved in the process are recorded as agents make their own decisions based on social, economic, and environmental opportunities presented in each population. For purposes of simplicity, this model places agents as the sole decision-makers unaffected by other neighboring agents unless they are related by blood. The ages of the agents including the newly created agents are randomly assigned from 1 to 100; agents are assumed to die at the age of 80. In addition, agents are also assigned families. The household size is determined by a proximity measure with a radius of 1. Family size is expected to increase for each agent when the population is more dense or concentrated in a certain area. 

The model consists of two populations, Country 1 and Country 2, denoted as green and red respectively. Throughout the course of the simulation, agents from both populations move across the border (represented by the yellow band in Figure 1) and relocate in the target country until the maximum population, indicated by the user, is reached. The maximum population refers to the point at which there is an excessive number of inhabitants exhausting the resources that the foreign country can afford. Once a population reaches its maximum, the simulation halts, signifying that the respective country can no longer allow any more immigrants entering the country. 

The agent’s decision to migrate is driven by a probability α. This probability is incremented in response to the agent’s demographics and educational level. These characteristics are used to calculate the agent’s attitude towards the perception of future opportunities presented in the foreign country. To better assess how an individual, given a set of circumstances and foreseen opportunities, makes the decision to migrate, the model examines the following: economic, social, and environmental factors. The weights of each factor contributing to α are shown in the following equation. 

α  = 0.11(x) + 0.44(y) + 0.33(z) + 0.05(q)

## HOW TO USE IT

Here is a summary of the parameters in the model.  They are explained in more detail below.

1. Sliders: 
- cntry1-population: initial number of agents in Country 1
- cntry2-population: initial number of agents in Country 2
- cntry1-pct-college-population: percent of agents seeking higher education in Country 1
- cntry2-pct-college-population: percent of agents seeking higher education in Country 2
- birthrate: assigned birthrate + 0.05 for Country specified as having better quality of life (chooser) 
- max-population: overpopulation limit
- threshold: threshold for the probability of migration

2. Choosers:
- quality-education: Country where there is better quality education
- quality-life: Country where there is better standards of living

3. Switches
- show-connection: shows how many family members each agent has
- natural-disaster: turns on natural disaster



## THINGS TO NOTICE

Adjusting the probability threshold alters the rate of migration from one country to another. A low value indicates higher susceptibility to migration thus increasing the migration rate. This would signify that agents are more open-minded towards the idea of relocating in search of better opportunities. 

The described model gives a rough approximation of how foreign and domestic factors contribute to migration rate.

## THINGS TO TRY

Run a number of experiments with the GO button to find out the effects of different variables on the rate of migration in both populations.  Try using good controls in your experiment.  Good controls are when only one variable is changed between trials.  

## EXTENDING THE MODEL

Like all computer simulations of human behaviors, this model has necessarily simplified its subject area substantially.  The model therefore provides numerous opportunities for extension. Here are some of the assumptions of the model:


The model assumes that individuals die at the age of 80. 
The ages of new-born agents are also randonly assigned. This means that a newborn can be of any age between 1 and 100. 
The weights of the different factors incorporated in the model are based entirely off of data from Statistics of Immigration in Norway. 
Once an agent is moved to other side of the environment, the agent is never going back to their home country
Family size is determined by proximity meaning it increases when the initial population is higher. 
The country with better quality of life is assumed to have higher birthrate. This assumption is based solely on an educated guess and is not supported by any research


Finally, certain significant changes can easily be made in the model by simply changing the values of the factors. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person lefty
false
0
Circle -7500403 true true 170 5 80
Polygon -7500403 true true 165 90 180 195 150 285 165 300 195 300 210 225 225 300 255 300 270 285 240 195 255 90
Rectangle -7500403 true true 187 79 232 94
Polygon -7500403 true true 255 90 300 150 285 180 225 105
Polygon -7500403 true true 165 90 120 150 135 180 195 105

person righty
false
0
Circle -7500403 true true 50 5 80
Polygon -7500403 true true 45 90 60 195 30 285 45 300 75 300 90 225 105 300 135 300 150 285 120 195 135 90
Rectangle -7500403 true true 67 79 112 94
Polygon -7500403 true true 135 90 180 150 165 180 105 105
Polygon -7500403 true true 45 90 0 150 15 180 75 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
