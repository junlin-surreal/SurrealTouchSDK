//
//  wrap.swift
//  SurrealTouchSDK
//
//  Created by DM on 2025/1/3.
//
import Foundation
import surreal_interactive_openxr_framework

public enum xr {
    
    public class Session {
        internal  var session :OpaquePointer? = nil
        internal var local_space :OpaquePointer? = nil
        public init(instance: Instance) {
             var sessionCreateInfo = XrSessionCreateInfo()
             sessionCreateInfo.type = XR_TYPE_SESSION_CREATE_INFO
             sessionCreateInfo.next = nil
             sessionCreateInfo.systemId = 1
             sessionCreateInfo.createFlags = 0;
             xrCreateSession(instance.instance, &sessionCreateInfo, &session)
                
            var  referenceSpaceCI = XrReferenceSpaceCreateInfo()
            referenceSpaceCI.type = XR_TYPE_REFERENCE_SPACE_CREATE_INFO
            
            referenceSpaceCI.referenceSpaceType = XR_REFERENCE_SPACE_TYPE_LOCAL;
            referenceSpaceCI.poseInReferenceSpace = XrPosef(orientation: XrQuaternionf(x: 0.0, y: 0.0, z: 0.0, w: 1.0), position: XrVector3f(x: 0.0, y: 0.0, z: 0.0))
            
            xrCreateReferenceSpace(session, &referenceSpaceCI, &local_space)

        }
        
        public func attachActionSet(actionSet : [ActionSet]) {
            var  actionSetAttachInfo =  XrSessionActionSetsAttachInfo()
            actionSetAttachInfo.type = XR_TYPE_SESSION_ACTION_SETS_ATTACH_INFO
            
            let action_set : [XrActionSet?] = actionSet.map{ action_set in
                return action_set.action_set
            }
            action_set.withUnsafeBufferPointer{ bufferPointer in
                actionSetAttachInfo.countActionSets = UInt32(action_set.count)
                actionSetAttachInfo.actionSets = bufferPointer.baseAddress;
            }
            xrAttachSessionActionSets(session, &actionSetAttachInfo);
        }
        
        public func syncActions(actionSet: [ActionSet]) {
            let active_c_action_set : [XrActiveActionSet] = actionSet.map { action_set in
                return XrActiveActionSet(actionSet: action_set.action_set, subactionPath: Path.nullPath().xr_path)
            }
            var actionsSyncInfo = XrActionsSyncInfo()
            actionsSyncInfo.type = XR_TYPE_ACTIONS_SYNC_INFO
            
            active_c_action_set.withUnsafeBufferPointer{ bufferPointer in
                actionsSyncInfo.countActiveActionSets = UInt32(active_c_action_set.count);
                actionsSyncInfo.activeActionSets = bufferPointer.baseAddress;
            }
            xrSyncActions(session, &actionsSyncInfo)
        }
        
        public func destory() -> Void {
            
        }
    }
    
    public class Bind<T> {
        internal var action : Action<T>
        internal var path : Path
        
        public init(action: Action<T>, path: Path) {
            self.action = action
            self.path =  path
        }
    }
    
    
    public class Instance {
        internal  var instance :OpaquePointer? = nil
        
        public init() {
            var create_info = XrInstanceCreateInfo()
            create_info.type = XR_TYPE_INSTANCE_CREATE_INFO
            let xr_result = xrCreateInstance(&create_info, &instance);
            print("Hello World From xr Instance \(xr_result), \(XR_SUCCESS)")
        }
        
        
        public func now() -> XrTime {
            return 0;
        }
        
        public func createSession() -> Session {
            return Session(instance:self)
        }
        
        public func createActionSet(actionSetName: String, localizedActionSetName: String) -> ActionSet {
            return ActionSet(instance: self, actionSetName: actionSetName, localizedActionSetName: localizedActionSetName)
        }
        
        public func suggestInteractionProfileBindings(profile_path: Path, binds: [Any]) {
            // XrActionSuggestedBinding suggestedBindings[] = {

               // };

               // // Suggest bindings for the action set
               var  interactionProfileSuggestedBinding = XrInteractionProfileSuggestedBinding()
                interactionProfileSuggestedBinding.type = XR_TYPE_INTERACTION_PROFILE_SUGGESTED_BINDING
                interactionProfileSuggestedBinding.interactionProfile = profile_path.xr_path
                
                var cArray: [XrActionSuggestedBinding] = binds.map { bind in
                    switch bind.self {
                        case let boolBind as Bind<Bool>:
                            return XrActionSuggestedBinding(action: boolBind.action.action, binding: boolBind.path.xr_path)
                        case let floatBind as Bind<Float>:
                            return XrActionSuggestedBinding(action: floatBind.action.action, binding: floatBind.path.xr_path)
                        case let poseBind as Bind<XrPosef>:
                            return XrActionSuggestedBinding(action: poseBind.action.action, binding: poseBind.path.xr_path)
                        default:
                            fatalError("Unhandled bind type: \(type(of: bind))")
                    }
                }
            
                cArray.withUnsafeBufferPointer { bufferPointer in
                    interactionProfileSuggestedBinding.suggestedBindings = bufferPointer.baseAddress
                    interactionProfileSuggestedBinding.countSuggestedBindings = UInt32(cArray.count)
                }
                xrSuggestInteractionProfileBindings(instance, &interactionProfileSuggestedBinding)
        }
        
        public func stringToPath(path_string:String) -> Path {
            return Path(instance:self, path_string: path_string)
        }
        public func destory() {
            
        }
    }
    
    public class ActionSet {
        internal  var action_set :OpaquePointer? = nil
        
        public init(instance: Instance, actionSetName: String, localizedActionSetName: String) {
            var actionSetCreateInfo = XrActionSetCreateInfo()
            
            actionSetCreateInfo.type = XR_TYPE_ACTION_SET_CREATE_INFO
            
            //actionSetCreateInfo.actionSetName = actionSetName.utf8.map {CChar($0)}
             //actionSetCreateInfo.localizedActionSetName = localizedActionSetName
             
            actionSetCreateInfo.priority = 0;
            // Create the action set
            xrCreateActionSet(instance.instance, &actionSetCreateInfo, &self.action_set)
        }
        public func createAction<T>(name: String, localized_name: String, subaction_paths: [Path]?) -> Action<T> {
            return Action<T>(actionSet: self, name: name, localized_name: localized_name, subaction_paths: subaction_paths)
        }
        
        
    }
    
    
    public class Space {
        internal var relatedAction : Action<XrPosef>
        internal var subActionPath : Path
        internal var space : OpaquePointer? = nil
        internal var session:Session
        public init(session:Session, action:Action<XrPosef>, subActionPath: Path, poseInActionSpace: XrPosef) {
            self.relatedAction = action
            self.session = session
            //let xrPoseIdentity = XrPosef(orientation: XrQuaternionf(x: 0.0, y: 0.0, z: 0.0, w: 1.0), position: XrVector3f(x: 0.0, y: 0.0, z: 0.0))
            
            // Create frame of reference for a pose action
            var  actionSpaceCI = XrActionSpaceCreateInfo()
            actionSpaceCI.type = XR_TYPE_ACTION_SPACE_CREATE_INFO
            
            actionSpaceCI.action = action.action;
            actionSpaceCI.poseInActionSpace = poseInActionSpace;
            actionSpaceCI.subactionPath = subActionPath.xr_path
            self.subActionPath = subActionPath
            xrCreateActionSpace(session.session, &actionSpaceCI, &space);
        }
        
        
        
        public func locate(predictedDisplayTime:XrTime) -> XrPosef {
            var actionStateGetInfo = XrActionStateGetInfo()
            actionStateGetInfo.type = XR_TYPE_ACTION_STATE_GET_INFO
            // We pose a single Action, twice - once for each subAction Path.
            actionStateGetInfo.action = relatedAction.action
            // For each hand, get the pose state if possible.
           
            actionStateGetInfo.subactionPath = subActionPath.xr_path
            var pose_state = XrActionStatePose()
            xrGetActionStatePose(session.session, &actionStateGetInfo, &pose_state)
            
            if pose_state.isActive != 0 {
                var spaceLocation = XrSpaceLocation()
                spaceLocation.type = XR_TYPE_SPACE_LOCATION
                let res : XrResult =
                xrLocateSpace(space, session.local_space, predictedDisplayTime, &spaceLocation);
                
                if res == XR_SUCCESS && (spaceLocation.locationFlags & XR_SPACE_LOCATION_ORIENTATION_VALID_BIT != 0 ) && (spaceLocation.locationFlags & XR_SPACE_LOCATION_POSITION_VALID_BIT != 0) {
                    return spaceLocation.pose
                }
            }
            return XrPosef(orientation: XrQuaternionf(x: 0.0, y: 0.0, z: 0.0, w: 1.0), position: XrVector3f(x: 0.0, y: 0.0, z: 0.0))
        }
    }
    
    public class Action<T> {
        internal  var action :OpaquePointer? = nil
        public init(actionSet:ActionSet, name: String, localized_name: String, subaction_paths: [Path]?) {
             var action_ci = XrActionCreateInfo()
             action_ci.type = XR_TYPE_ACTION_CREATE_INFO;
             switch T.self {
                    case is Float.Type:
                 action_ci.actionType =  XR_ACTION_TYPE_FLOAT_INPUT
                    case is Bool.Type:
                 action_ci.actionType = XR_ACTION_TYPE_BOOLEAN_INPUT
                    case is XrPosef.Type:
                 action_ci.actionType = XR_ACTION_TYPE_POSE_INPUT
                    default:
                 action_ci.actionType =  XR_ACTION_TYPE_MAX_ENUM // Replace with the default XrActionType
            }
            if let paths = subaction_paths {
                action_ci.countSubactionPaths = UInt32(paths.count)
                //action_ci.subactionPaths = subaction_paths
            } else {
                action_ci.countSubactionPaths = 0
            }
            
            //strncpy(action_ci.actionName, name, XR_MAX_ACTION_NAME_SIZE);
            //strncpy(action_ci.localizedActionName, name, XR_MAX_LOCALIZED_ACTION_NAME_SIZE);
            xrCreateAction(actionSet.action_set, &action_ci, &action)
        }
        
       
        
        public func isActive(session:Session) -> Bool {
            return false
        }
        public func ApplyHapticFeedBack(session:Session, amplitude:Float, frequency: Float, duration: Float) -> Void {
            
        }
    }
    
   
    
    public class Path {
        internal var xr_path : XrPath
        
        public init(instance:Instance, path_string:String) {
            self.xr_path = XrPath(XR_NULL_PATH)
            xrStringToPath(instance.instance, path_string, &self.xr_path)
        }
        
        private init() {
            self.xr_path = XrPath(XR_NULL_PATH)
        }
        public static func nullPath() -> Path {
            return Path()
        }
    }
    /*
    public class Posef {
        
        public static func identity() -> Posef {
            return Posef()
        }
    }
     */
    
    public class Haptic {
        
    }
   
}

public func HelloWorld() -> String {
    return "wrap String"
}

extension xr.Action where T == XrPosef {
    public func createSpace(session:xr.Session, path: xr.Path, poseInReference: XrPosef) -> xr.Space {
        
        return xr.Space(session:session, action: self, subActionPath:xr.Path.nullPath(), poseInActionSpace: poseInReference)
    }
}
