"
A Sequencer is a bidimensional Array containing two arrays, to feed the sequenceFor: aDictionary rate: aNumber method.
The first array contains the gates, the second array contains the notes, the third array contains the durations.
"
Class {
	#name : #Sequencer,
	#superclass : #Array,
	#type : #variable,
	#category : #LiveCoding
}

{ #category : #'as yet unclassified' }
Sequencer >> durations [
" returns the third array of the seuencer if there is one, otherwise returns false"
(self size > 2)
ifTrue: [ ^ (self at: 3)] ifFalse: [ ^ false ].

]

{ #category : #'as yet unclassified' }
Sequencer >> durationsSize [

^ ((self at: 3) size)
]

{ #category : #'as yet unclassified' }
Sequencer >> gates [

^ (self at: 1)
]

{ #category : #'as yet unclassified' }
Sequencer >> gatesSize [

^ ((self at: 1) size)
]

{ #category : #testing }
Sequencer >> isSequencer [

(((self size) > 1) & ((self at: 1) isArray ))
ifTrue: [  ^ true ] ifFalse: [ ^ false ]
]

{ #category : #'as yet unclassified' }
Sequencer >> notes [

^ (self at: 2)
]

{ #category : #'as yet unclassified' }
Sequencer >> notesSize [

^ ((self at: 2) size)
]