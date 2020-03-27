// Code generated by "stringer -type NodeType ."; DO NOT EDIT.

package main

import "strconv"

func _() {
	// An "invalid array index" compiler error signifies that the constant values have changed.
	// Re-run the stringer command to generate them again.
	var x [1]struct{}
	_ = x[NodeNil-0]
	_ = x[NodeT-1]
	_ = x[NodeInt-2]
	_ = x[NodeDouble-3]
	_ = x[NodeString-4]
	_ = x[NodeQuote-5]
	_ = x[NodeBquote-6]
	_ = x[NodeIdent-7]
	_ = x[NodeLambda-8]
	_ = x[NodeSpecial-9]
	_ = x[NodeBuiltinfunc-10]
	_ = x[NodeCell-11]
	_ = x[NodeAref-12]
	_ = x[NodeEnv-13]
	_ = x[NodeError-14]
}

const _NodeType_name = "NodeNilNodeTNodeIntNodeDoubleNodeStringNodeQuoteNodeBquoteNodeIdentNodeLambdaNodeSpecialNodeBuiltinfuncNodeCellNodeArefNodeEnvNodeError"

var _NodeType_index = [...]uint8{0, 7, 12, 19, 29, 39, 48, 58, 67, 77, 88, 103, 111, 119, 126, 135}

func (i NodeType) String() string {
	if i < 0 || i >= NodeType(len(_NodeType_index)-1) {
		return "NodeType(" + strconv.FormatInt(int64(i), 10) + ")"
	}
	return _NodeType_name[_NodeType_index[i]:_NodeType_index[i+1]]
}
