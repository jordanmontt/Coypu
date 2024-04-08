"
A performance is a Dictionary subclass used for live coding package.


"
Class {
	#name : #Performance,
	#superclass : #Dictionary,
	#type : #variable,
	#instVars : [
		'visualization',
		'performer',
		'canvas',
		'rsGroupDictionary',
		'freq',
		'backup',
		'bpm',
		'transportStep',
		'activeProcess',
		'dirtMIDIDevice',
		'activeDSP'
	],
	#classInstVars : [
		'uniqueInstance',
		'orbit'
	],
	#category : #'Coypu-Performance'
}

{ #category : #'as yet unclassified' }
Performance class >> basic [

	^ self new
		  visualization: NoneVisualization new;
		  yourself
]

{ #category : #'instance creation' }
Performance class >> new [ 

^ Error new signal: 'Performance is a singleton -- Use unique instance instead'
]

{ #category : #accessing }
Performance class >> orbit [

	^ orbit
]

{ #category : #accessing }
Performance class >> orbit: anInteger [

	orbit := anInteger % 12
]

{ #category : #'instance creation' }
Performance class >> uniqueInstance [

	self orbit: 0.
	^ uniqueInstance ifNil: [ uniqueInstance := super new ]
]

{ #category : #'as yet unclassified' }
Performance class >> withCanvas: aRSCanvas [

	^ self new
		  canvas: aRSCanvas;
		  freq: 120 bpm;
		  rsGroupDictionary: Dictionary new
]

{ #category : #'as yet unclassified' }
Performance class >> withCircles [

	^ self new
		  visualization: CircleVisualization new;
		  yourself
]

{ #category : #'as yet unclassified' }
Performance >> Dictionary [  Variable or expression expected -><< #Performance
	layout: VariableLayout;
	slots: {
			 #visualization .
			 #performer .
			 #canvas .
			 #rsGroupDictionary .
			 #freq .
			 #backup .
			 #bpm .
			 #transportStep .
			 #activeProcess.
			 };
	tag: 'Performance';
	package: 'LiveCoding'
]

{ #category : #accessing }
Performance >> activeDSP [
^ activeDSP 
]

{ #category : #accessing }
Performance >> activeDSP: aDSP [
activeDSP := aDSP
]

{ #category : #accessing }
Performance >> activeProcess [

	^ activeProcess
]

{ #category : #accessing }
Performance >> activeProcess: anObject [

	activeProcess := anObject
]

{ #category : #'performance  - adding' }
Performance >> add: aSequencer channel: anIntegerBetween1And16 [

aSequencer midiChannel: anIntegerBetween1And16. 
super add: aSequencer.
]

{ #category : #accessing }
Performance >> at: key put: anObject [

	"Set the value at key to be anObject.  If key is not found, create a
	new entry for key and set is value to anObject. Answer anObject.
	If a RsCanvas have been associated to the Performance add the visualisation of the sequencer to the RSCanvas"


	super at: key put: anObject.

	canvas isNotNil & anObject isSequencer ifTrue: [ 
		(self rsGroupDictionary includesKey: key)
			ifTrue: [ 
				canvas removeShape: (rsGroupDictionary at: key) asShape.
				anObject visualizeOn: canvas.
				rsGroupDictionary at: key put: anObject visualGroup ]
			ifFalse: [ 
				anObject visualizeOn: canvas.
				rsGroupDictionary at: key put: anObject visualGroup ] ]
]

{ #category : #'LiveCoding - Performance' }
Performance >> backup [

	
	^ backup
]

{ #category : #accessing }
Performance >> backup: anObject [

	backup := anObject
]

{ #category : #accessing }
Performance >> bpm [

	^ bpm
]

{ #category : #accessing }
Performance >> bpm: aRateInSeconds [

	bpm := 60 / 4 / (aRateInSeconds ).
]

{ #category : #accessing }
Performance >> canvas [ 
^ canvas 
]

{ #category : #accessing }
Performance >> canvas: aRSCanvas [
canvas := aRSCanvas 
]

{ #category : #accessing }
Performance >> dirtMIDIDevice [

	^ dirtMIDIDevice
]

{ #category : #accessing }
Performance >> dirtMIDIDevice: aString [
"select a SuperDirt MIDI device for the Performance"
	dirtMIDIDevice := aString
]

{ #category : #accessing }
Performance >> freq [
"better to convert it to Float to avoid OSC sending issues"
^ freq asFloat
]

{ #category : #accessing }
Performance >> freq1: anObject [

	freq := anObject
]

{ #category : #accessing }
Performance >> freq: aDurationInSeconds [

	"use for playback speed"

	freq := aDurationInSeconds asFloat
]

{ #category : #'LiveCoding - Performance' }
Performance >> incrementTransportStep [
	transportStep := transportStep + 1.
]

{ #category : #initialization }
Performance >> initialize: aSize [
super initialize: aSize.
activeProcess := Process new terminate.
freq := 132 bpm.
]

{ #category : #testing }
Performance >> isPerformance [

^ true
]

{ #category : #accessing }
Performance >> length [
"return the number of steps of the largest array contained in the performance values"
| valuesSizes maxLength |
valuesSizes := (1 to: (self values size)) collect: [ :i | ((self values at: i) at: 1 )size ].
maxLength := valuesSizes inject: 0 into: [ :a :c | (a > c) ifTrue: [ a ] ifFalse: [ c ] ].
^ maxLength 
]

{ #category : #'muting and soloing' }
Performance >> mute: aKeyOrAnArrayOfKeys [

	"remove all the keys in the arrayOfKeys from the Performance or remove just a single key"

	aKeyOrAnArrayOfKeys isArray
		ifTrue: [ 
		aKeyOrAnArrayOfKeys do: [ :i | self removeKey: i ifAbsent: [  ] ] ]
		ifFalse: [ self removeKey: aKeyOrAnArrayOfKeys ].
	"if the Performance has an associated canvas, it also removes the shapes group visualizing the key sequencer"
	canvas isNotNil ifTrue: [ 
		aKeyOrAnArrayOfKeys isArray
			ifTrue: [ 
				aKeyOrAnArrayOfKeys do: [ :i | 
					canvas removeShape: (rsGroupDictionary at: i) asShape ] ]
			ifFalse: [ 
				canvas removeShape:
					(rsGroupDictionary at: aKeyOrAnArrayOfKeys) asShape ]. canvas signalUpdate  ]
]

{ #category : #'muting and soloing' }
Performance >> muteAll [

	" remove all keys from the Performance"

	| anArrayOfKeys |
	backup := self asDictionary .
	self keysDo: [ :i | self removeKey: i ifAbsent: [ nil ] ].

	[ 
	canvas isNotNil ifTrue: [ 
		anArrayOfKeys do: [ :i | 
			canvas removeShape: (rsGroupDictionary at: i) asShape ] ] ] fork
]

{ #category : #'LiveCoding - satelliteEvent' }
Performance >> pacaDance [

	"convenience method created for the ICLC2023 performance - it just play the performance at 132 bpm for 4096 bars"

	
	| aRateInSeconds aNumberOfSteps step bpm beatInSeconds gateTime |
	aRateInSeconds := 132 bpm.
	aNumberOfSteps := 4096 bars.
	'x' asPacaAddress. "if PacaAddress is not stored yet"
	self resetAllSequencers. "reset all the sequencers"
	"as in early hardware sequencers, default gatetime is 80% of the step duration"

	bpm := 60 / (aRateInSeconds * 4).

	gateTime := aRateInSeconds * 0.8.
	beatInSeconds := aRateInSeconds * 4.
	step := 0.


	^ [ 
	  bpm toKyma: 'BPM'.


	  aNumberOfSteps timesRepeat: [ 
		  (Delay forSeconds: aRateInSeconds) wait.
		  " test if dictionary values is an Array of two arrays or as defined, a sequence"

		  self keysAndValuesDo: [ :key :value | 
			  value isSequencer
				  ifTrue: [ 
					  (value gates at: (step modulo: value gatesSize)) = 1
						  ifTrue: [ 
							  | note |
							  note := value notes at:
								          (value noteIndex modulo: value notesSize).
							  key asString
								  toKymaAsGate: gateTime
									  *
									  (value durations at:
										   (value noteIndex modulo: value durationsSize))
								  note: note.

							  "maybe this part is not useful anymore"
							  value durations isArray
								  ifTrue: [ 
									  (value durations at:
										   (value noteIndex modulo: value durationsSize)) toKyma:
										  key asString , 'Duration' ]
								  ifFalse: [ nil ].

							  "experimental, for extra control parameter"
							  value extra1 notNil
								  ifTrue: [ 
									  ((value extra1 at: 2) at:
										   (value noteIndex modulo: value extra1Size)) toKyma:
										  key asString , (value extra1 at: 1) ]
								  ifFalse: [ nil ].

							  "new experimental, for second extra control"
							  value extra2 notNil
								  ifTrue: [ 
									  ((value extra2 at: 2) at:
										   (value noteIndex modulo: value extra2Size)) toKyma:
										  key asString , (value extra2 at: 1) ]
								  ifFalse: [ nil ].


							  value noteIndex: value noteIndex + 1

							  "noteIndex := noteIndex + 1." ]
						  ifFalse: [ nil ] ]
				  ifFalse: [ 
				  (value at: (step modulo: value size)) toKyma: key asString ] ].

		  "step is incrementing in any case"
		  step := step + 1 ] ] forkAt: Processor timingPriority
]

{ #category : #accessing }
Performance >> performer [

	^ performer
]

{ #category : #accessing }
Performance >> performer: aPerformer [
"choose a Performer for the Performance"
" to be safe, it clear the performance"
Performance uniqueInstance muteAll.
performer := aPerformer. 
Performance uniqueInstance muteAll.
]

{ #category : #playing }
Performance >> play [
" reset all the Sequencers"
self resetAllSequencers .

"just on performance at once"
self activeProcess  ifNil:  [ self performer play ] ifNotNil: [(self activeProcess isTerminated )ifTrue: [ self performer play ] ifFalse: [ ] ]
.


	
]

{ #category : #playing }
Performance >> playFor: aNumberOfSteps [


" reset all the Sequencers"
self resetAllSequencers .

"just on performance at once"
( self activeProcess isTerminated) ifTrue: [ self performer playFor: aNumberOfSteps  ] ifFalse:[].


]

{ #category : #'as yet unclassified' }
Performance >> playKymaSequencFor: aNumberOfSteps [

"with this method you can chane the Performance speed in real time! "
	" iterate over a process for self times, at a rate of aRateInMilliSeconds for step, through a dictionary of patterns, containing arrays of numbers as values and symbols represnting the OSC address without slash that will be sent out.
an OSC with the address /vcs/BPM/1 with the rate converted in BeatsPerMinutes"

	| step bpm beatInSeconds gateTime |
	'x' asPacaAddress. "if PacaAddress is not stored yet"
	self resetAllSequencers. "reset all the sequencers"
	"as in early hardware sequencers, default gatetime is 80% of the step duration"


	step := 0.


	^ [ 
	  bpm := 60 / (self freq * 4).

	  gateTime := self freq * 0.8.
	  beatInSeconds := self freq * 4.
	  bpm toKyma: 'BPM'.


	  aNumberOfSteps timesRepeat: [ 
		  (Delay forSeconds: self freq) wait.
		  " test if dictionary values is an Array of two arrays or as defined, a sequence"

		  self keysAndValuesDo: [ :key :value | 
			  value isSequencer
				  ifTrue: [ 
					  (value gates at: (step modulo: value gatesSize)) = 1
						  ifTrue: [ 
							  | note |
							  note := value notes at:
								          (value noteIndex modulo: value notesSize).
							  key asString
								  toKymaAsGate: gateTime
									  *
									  (value durations at:
										   (value noteIndex modulo: value durationsSize))
								  note: note.

							  "maybe this part is not useful anymore"
							  value durations isArray
								  ifTrue: [ 
									  (value durations at:
										   (value noteIndex modulo: value durationsSize)) toKyma:
										  key asString , 'Duration' ]
								  ifFalse: [ nil ].

							  "experimental, for extra control parameter"
							  value extra1 notNil
								  ifTrue: [ 
									  ((value extra1 at: 2) at:
										   (value noteIndex modulo: value extra1Size)) toKyma:
										  key asString , (value extra1 at: 1) ]
								  ifFalse: [ nil ].

							  "new experimental, for second extra control"
							  value extra2 notNil
								  ifTrue: [ 
									  ((value extra2 at: 2) at:
										   (value noteIndex modulo: value extra2Size)) toKyma:
										  key asString , (value extra2 at: 1) ]
								  ifFalse: [ nil ].


							  value noteIndex: value noteIndex + 1

							  "noteIndex := noteIndex + 1." ]
						  ifFalse: [ nil ] ]
				  ifFalse: [ 
				  (value at: (step modulo: value size)) toKyma: key asString ] ].

		  "step is incrementing in any case"
		  step := step + 1 ] ] forkAt: Processor timingPriority
]

{ #category : #playing }
Performance >> playKymaSequenceAt: aRateInSeconds for: aNumberOfSteps [

	" iterate over a process for self times, at a rate of aRateInMilliSeconds for step, through a dictionary of patterns, containing arrays of numbers as values and symbols represnting the OSC address without slash that will be sent out.
an OSC with the address /vcs/BPM/1 with the rate converted in BeatsPerMinutes"

	| step bpm beatInSeconds gateTime |
	'x' asPacaAddress. "if PacaAddress is not stored yet"
	self resetAllSequencers. "reset all the sequencers"
	"as in early hardware sequencers, default gatetime is 80% of the step duration"

	bpm := 60 / (aRateInSeconds * 4).

	gateTime := aRateInSeconds * 0.8.
	beatInSeconds := aRateInSeconds * 4.
	step := 0.


	^ [ 
	 
	  bpm toKyma: 'BPM'.


	  aNumberOfSteps timesRepeat: [ 
		  (Delay forSeconds: aRateInSeconds) wait.
		  " test if dictionary values is an Array of two arrays or as defined, a sequence"

		  self keysAndValuesDo: [ :key :value | 
			  value isSequencer
				  ifTrue: [ 
					  (value gates at: (step modulo: value gatesSize)) = 1
						  ifTrue: [ 
							  | note |
							  note := value notes at:
								          (value noteIndex modulo: value notesSize).
							  key asString
								  toKymaAsGate: gateTime
									  *
									  (value durations at:
										   (value noteIndex modulo: value durationsSize))
								  note: note.

							  "maybe this part is not useful anymore"
							  value durations isArray
								  ifTrue: [ 
									  (value durations at:
										   (value noteIndex modulo: value durationsSize)) toKyma:
										  key asString , 'Duration' ]
								  ifFalse: [ nil ].

							  "experimental, for extra control parameter"
							  value extra1 notNil
								  ifTrue: [ 
									  ((value extra1 at: 2) at:
										   (value noteIndex modulo: value extra1Size)) toKyma:
										  key asString , (value extra1 at: 1) ]
								  ifFalse: [ nil ].

							  "new experimental, for second extra control"
							  value extra2 notNil
								  ifTrue: [ 
									  ((value extra2 at: 2) at:
										   (value noteIndex modulo: value extra2Size)) toKyma:
										  key asString , (value extra2 at: 1) ]
								  ifFalse: [ nil ].


							  value noteIndex: value noteIndex + 1

							  "noteIndex := noteIndex + 1." ]
						  ifFalse: [ nil ] ]
				  ifFalse: [ 
				  (value at: (step modulo: value size)) toKyma: key asString ] ].

		  "step is incrementing in any case"
		  step := step + 1 ] ] forkAt: Processor timingPriority
]

{ #category : #'as yet unclassified' }
Performance >> playLocalSequenceAt: aRateInSeconds for: aNumberOfSteps [

	" iterate over a process for self times, at a rate of aRateInMilliSeconds for step, through a dictionary of patterns, containing arrays of numbers as values and symbols represnting the OSC address without slash that will be sent out.
an OSC with the address /vcs/BPM/1 with the rate converted in BeatsPerMinutes"

	"if the value in the dictionay is a Sequencer, an OSC message is sent to the key as OSC address with two arguments, one for the gate, and one for the note. the gate stays at 1 for the duration selected."

	| step bpm beatInSeconds gateTime |
	bpm := 60 / (aRateInSeconds * 4).
	gateTime := aRateInSeconds * 0.8.
	beatInSeconds := aRateInSeconds * 4.
	step := 0.

	^ [ 
	  bpm toLocal: 'BPM/'.

	  aNumberOfSteps timesRepeat: [ 
		  (Delay forSeconds: aRateInSeconds) wait.
		  " test if dictionary values is an Array of two arrays or as defined, a sequence"

		  self keysAndValuesDo: [ :key :value | 
			  value isSequencer
				  ifTrue: [ 
					  (value gates at: (step modulo: value gatesSize)) = 1
						  ifTrue: [ 
							  | note |
							  note := value notes at:
								          (value noteIndex modulo: value notesSize).
							  key asString
								  toLocalAsGate: gateTime
									  *
									  (value durations at:
										   (value noteIndex modulo: value durationsSize))
								  note: note.


							  "experimental, for extra control parameter"
							  value extra1 notNil
								  ifTrue: [ 
									  ((value extra1 at: 2) at:
										   (value noteIndex modulo: value extra1Size)) toLocal:
										  key asString , (value extra1 at: 1) ]
								  ifFalse: [ nil ].
							  value noteIndex: value noteIndex + 1 ]
						  ifFalse: [ nil ] ]
				  ifFalse: [ 
				  (value at: (step modulo: value size)) toLocal: key asString ] ].

		  "step is incrementing in any case"
		  step := step + 1 ] ] forkAt: Processor timingPriority
]

{ #category : #removing }
Performance >> remove: aKey [
"shorter version of removeKey:"

self removeKey: aKey ifAbsent: [  ] 
]

{ #category : #initialization }
Performance >> resetAllSequencers [
	"reset noteIndex fro all the sequencers in the Performance. "

	self keysAndValuesDo: [ :key :value |
		value isSequencer
			ifTrue: [ value noteIndex: 1 ]
			ifFalse: [ nil ] ]
]

{ #category : #'LiveCoding - Performance' }
Performance >> restore [

	"restore what the performance was before receiveing messages muteAll or solo"

	| p |
	p := Performance uniqueInstance.
	self backup keysAndValuesDo: [ :k :v | 
		p at: k put: v].
	p keysAndValuesRemove: [ :kp :vp | (p backup includesKey: kp) not ] 
]

{ #category : #accessing }
Performance >> rsGroupDictionary [

	^ rsGroupDictionary
]

{ #category : #accessing }
Performance >> rsGroupDictionary: anRSGroupDictionary [

	rsGroupDictionary := anRSGroupDictionary
]

{ #category : #'muting and soloing' }
Performance >> solo: aKeyOrAnArrayOfKeys [

	" remove all keys from the Performance except aKey or anArrayOfKeys"

	| anArrayOfKeys |
	backup := self asDictionary. "do the backup"
	anArrayOfKeys := self keys.
	aKeyOrAnArrayOfKeys isArray
		ifTrue: [ 
			self keysAndValuesRemove: [ :keys :values | 
				(aKeyOrAnArrayOfKeys  includes: keys) not ] ]
		ifFalse: [ 
			self keysAndValuesRemove: [ :keys :values | "
	[canvas isNotNil ifTrue: [ 
		anArrayOfKeys do: [ :i | (i ~= aKey) ifTrue: [  
			canvas removeShape: (rsGroupDictionary at: i) asShape ] ]] ] fork
" 
				keys ~= aKeyOrAnArrayOfKeys ] ]
]

{ #category : #accessing }
Performance >> stop [
	self activeProcess terminate
]

{ #category : #modifying }
Performance >> swap: firstKey with: secondKey [
"swap the values of two perfromance keys"
	| tempValue |
	tempValue := self at: firstKey.
	self at: firstKey put: (self at: secondKey).
	self at: secondKey put: tempValue
]

{ #category : #accessing }
Performance >> transportStep [
	^ transportStep
]

{ #category : #accessing }
Performance >> transportStep: anInteger [

	transportStep := anInteger 
]

{ #category : #'LiveCoding - Performance' }
Performance >> unsolo: aKeyInPerformance [
	"convenience method to unsolo a key in the performance"
	
self restore
]

{ #category : #accessing }
Performance >> visualization [

	^ visualization
]

{ #category : #accessing }
Performance >> visualization: anObject [

	visualization := anObject
]