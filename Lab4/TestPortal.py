import PortalConnection

def pause():
  input("Press Enter to continue...")
  print("")

if __name__ == "__main__":        
    c = PortalConnection.PortalConnection()
    
    # Write your tests here. Add/remove calls to pause() as desired. 
    
    print("Test 1:")
    print(c.unregister("2222222222", "CCC333"))
    print(c.getInfo("2222222222"))
    pause()
    
    print("Test 2:")
    print(c.register("2222222222", "CCC333")); 
    print(c.getInfo("2222222222"))
    pause()
    
    