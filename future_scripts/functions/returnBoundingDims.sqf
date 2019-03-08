/*
	File: returnBoundingDims.sqf
	Description: returns the dimensions of the bounding box for a given object.
	
	Copyright © Bohemia Interactive Studio. All rights reserved.
*/

private ["_obj"];
_obj = _this select 0;

private ["_boundBox", "_bbPos1", "_bbPos2"];
_boundBox = boundingBox _obj;
_bbPos1 = _obj modelToWorld (_boundBox select 0);
_bbPos2 = _obj modelToWorld (_boundBox select 1);

private ["_xDim", "_yDim", "_zDim"];
_xDim = abs ((_bbPos1 select 0) - (_bbPos2 select 0));
_yDim = abs ((_bbPos1 select 1) - (_bbPos2 select 1));
_zDim = abs ((_bbPos1 select 2) - (_bbPos2 select 2));

[_xDim, _yDim, _zDim]